resource "aws_subnet" "public" {
  count             = var.existing_public_subnet_id == "" ? 1 : 0
  vpc_id            = var.existing_vpc_id == "" ? aws_vpc.main[0].id : var.existing_vpc_id
  cidr_block        = var.public_subnet_full
  availability_zone = "${var.region}a"

  tags = merge(
    local.commonTags,
    tomap(
      { "Name" = "${local.commonTags.Environment}-WebAZ1-${local.commonTags.Client}" }
    )
  )
}

resource "aws_subnet" "databricks_az1" {
  count             = var.existing_databricks_az1_subnet_id == "" ? 1 : 0
  vpc_id            = var.existing_vpc_id == "" ? aws_vpc.main[0].id : var.existing_vpc_id
  cidr_block        = var.databricks_az1_subnet_full
  availability_zone = "${var.region}a"

  tags = merge(
    local.commonTags,
    tomap(
      { "Name" = "${local.commonTags.Environment}-DatabricksAZ1-${local.commonTags.Client}" }
    )
  )
}

resource "aws_subnet" "databricks_az2" {
  count             = var.existing_databricks_az2_subnet_id == "" ? 1 : 0
  vpc_id            = var.existing_vpc_id == "" ? aws_vpc.main[0].id : var.existing_vpc_id
  cidr_block        = var.databricks_az2_subnet_full
  availability_zone = var.region == "us-west-1" ? "${var.region}c" : "${var.region}b"

  tags = merge(
    local.commonTags,
    tomap(
      { "Name" = "${local.commonTags.Environment}-DatabricksAZ2-${local.commonTags.Client}" }
    )
  )
}