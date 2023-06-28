data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "instance_profile_role" {
  name               = "${local.commonTags.Environment}-instance-profile-role-${local.commonTags.Client}"
  description        = "${local.commonTags.Environment}-${local.commonTags.Client} Databricks Instance Profile Role for S3 and EC2 access"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
  tags               = local.commonTags
}

data "aws_iam_policy_document" "datalake_s3_access" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.main.arn]
  }
  statement {
    effect = "Allow"
    actions = ["s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
    "s3:PutObjectAcl"]
    resources = ["${aws_s3_bucket.main.arn}/*"]
  }
}

resource "aws_iam_policy" "datalake_s3_policy" {
  name   = "${local.commonTags.Environment}-datalake-s3-policy-${local.commonTags.Client}"
  policy = data.aws_iam_policy_document.datalake_s3_access.json
  lifecycle {
    ignore_changes = [policy]
  }
}

resource "aws_iam_role_policy_attachment" "datalake_s3_attachment" {
  role       = aws_iam_role.instance_profile_role.name
  policy_arn = aws_iam_policy.datalake_s3_policy.arn
}

resource "aws_iam_instance_profile" "main" {
  name = "${local.commonTags.Environment}-instance-profile-${local.commonTags.Client}"
  role = aws_iam_role.instance_profile_role.name
}


data "databricks_aws_bucket_policy" "databricks_master_access" {
  provider         = databricks.mws
  full_access_role = "arn:aws:iam::414351767826:root" //Databricks master account
  bucket           = aws_s3_bucket.main.bucket
}

// allow Databricks master account to access this bucket
resource "aws_s3_bucket_policy" "databricks_master_access_policy" {
  bucket = aws_s3_bucket.main.id
  policy = data.databricks_aws_bucket_policy.databricks_master_access.json
}

data "databricks_aws_assume_role_policy" "main" {
  external_id = var.databricks_account_id
}

resource "aws_iam_role" "cross_account_role" {
  name               = "${local.commonTags.Environment}-cross-account-${local.commonTags.Client}"
  assume_role_policy = data.databricks_aws_assume_role_policy.main.json
  tags               = local.commonTags
}

data "databricks_aws_crossaccount_policy" "main" {
  pass_roles = [aws_iam_role.instance_profile_role.arn]
}

resource "aws_iam_role_policy" "cross_account" {
  name   = "${local.commonTags.Environment}-databricks-cross-account-${local.commonTags.Client}"
  role   = aws_iam_role.cross_account_role.id
  policy = data.databricks_aws_crossaccount_policy.main.json
}

resource "databricks_mws_credentials" "main" {
  provider         = databricks.mws
  account_id       = var.databricks_account_id
  role_arn         = aws_iam_role.cross_account_role.arn
  credentials_name = "${local.commonTags.Environment}-mws-credentials-${local.commonTags.Client}"

  // not explicitly needed by this, but to make sure a smooth deployment
  depends_on = [aws_iam_role_policy.cross_account]
}

// register root bucket
resource "databricks_mws_storage_configurations" "main" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.main.bucket
  storage_configuration_name = "${local.commonTags.Environment}-mws-storage-${local.commonTags.Client}"
}