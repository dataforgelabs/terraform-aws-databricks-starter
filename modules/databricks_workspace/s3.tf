resource "aws_s3_bucket" "main" {
  bucket = lower("${local.commonTags.Environment}-datalake-${local.commonTags.Client}")

  tags = merge(
    local.commonTags,
    tomap(
      { "Name" = "${local.commonTags.Environment}-Datalake-${local.commonTags.Client}" }
    )
  )

}

resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    id     = lower("${local.commonTags.Environment}-datalake-tiering-${local.commonTags.Client}")
    status = "Enabled"

    transition {
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
