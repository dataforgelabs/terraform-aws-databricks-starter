#VPCEincrendpoint
#TODO: tighten the restrictions on resource 
resource "aws_vpc_endpoint" "s3" {
  vpc_id = var.existing_vpc_id == "" ? aws_vpc.main[0].id : var.existing_vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
  policy       = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*",
      "Principal": "*"
    }
  ]
}
  EOF

  tags = merge(
    local.commonTags,
    tomap(
      {"Name" = "${local.commonTags.Environment}-VpcEndpoint"}
    )
  )
}

resource "aws_internet_gateway" "main" {
  count  = var.existing_internet_gateway_id == "" ? 1 : 0
  vpc_id = var.existing_vpc_id == "" ? aws_vpc.main[0].id : var.existing_vpc_id

  tags = merge(
    local.commonTags,
    tomap(
      { "Name" = "${local.commonTags.Environment}-InternetGateway" }
    )
  )
}

resource "aws_eip" "nat_ip" {
  count = var.existing_nat_gateway_id == "" ? 1 : 0
  vpc   = true

  tags = merge(
    local.commonTags,
    tomap(
      { "Name" = "${local.commonTags.Environment}-ElasticIp" }
    )
  )
}

resource "aws_nat_gateway" "main" {
  count         = var.existing_nat_gateway_id == "" ? 1 : 0
  allocation_id = aws_eip.nat_ip[0].id
  subnet_id     = var.existing_public_subnet_id == "" ? aws_subnet.public[0].id : var.existing_public_subnet_id

  tags = merge(
    local.commonTags,
    tomap(
      { "Name" = "${local.commonTags.Environment}-NatGateway" }
    )
  )
}


resource "aws_route_table" "public" {
  count  = var.existing_public_route_table_id == "" ? 1 : 0
  vpc_id = var.existing_vpc_id == "" ? aws_vpc.main[0].id : var.existing_vpc_id
  route {
    gateway_id = var.existing_internet_gateway_id == "" ? aws_internet_gateway.main[0].id : var.existing_internet_gateway_id
    cidr_block = "0.0.0.0/0"
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = merge(
    local.commonTags,
    tomap(
      { "Name" = "${local.commonTags.Environment}-External" }
    )
  )
}

resource "aws_route_table" "internal" {
  count  = var.existing_internal_route_table_id == "" ? 1 : 0
  vpc_id = var.existing_vpc_id == "" ? aws_vpc.main[0].id : var.existing_vpc_id

  route {
    nat_gateway_id = var.existing_nat_gateway_id == "" ? aws_nat_gateway.main[0].id : var.existing_nat_gateway_id
    cidr_block     = "0.0.0.0/0"
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = merge(
    local.commonTags,
    tomap(
      { "Name" = "${local.commonTags.Environment}-Internal" }
    )
  )
}

resource "aws_route_table_association" "public_rt_public_subnet" {
  count          = var.existing_public_route_table_id == "" ? 1 : 0
  subnet_id      = var.existing_public_subnet_id == "" ? aws_subnet.public[0].id : var.existing_public_subnet_id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "internal_rt_databricks_az1_subnet" {
  count          = var.existing_internal_route_table_id == "" ? 1 : 0
  subnet_id      = var.existing_databricks_az1_subnet_id == "" ? aws_subnet.databricks_az1[0].id : var.existing_databricks_az1_subnet_id
  route_table_id = aws_route_table.internal[0].id
}

resource "aws_route_table_association" "internal_rt_databricks_az2_subnet" {
  count          = var.existing_internal_route_table_id == "" ? 1 : 0
  subnet_id      = var.existing_databricks_az2_subnet_id == "" ? aws_subnet.databricks_az2[0].id : var.existing_databricks_az2_subnet_id
  route_table_id = aws_route_table.internal[0].id
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name         = "${var.region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = merge(
    local.commonTags,
    tomap(
      { "Name" = "${local.commonTags.Environment}-DHCPInternalComputer" }
    )
  )
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = var.existing_vpc_id == "" ? aws_vpc.main[0].id : var.existing_vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_network_acl" "main" {
  vpc_id = var.existing_vpc_id == "" ? aws_vpc.main[0].id : var.existing_vpc_id
  subnet_ids = [var.existing_public_subnet_id == "" ? aws_subnet.public[0].id : var.existing_public_subnet_id,
    var.existing_databricks_az1_subnet_id == "" ? aws_subnet.databricks_az1[0].id : var.existing_databricks_az1_subnet_id,
  var.existing_databricks_az2_subnet_id == "" ? aws_subnet.databricks_az2[0].id : var.existing_databricks_az2_subnet_id]
  egress {
    cidr_block = "0.0.0.0/0"
    rule_no    = 100
    protocol   = -1
    action     = "allow"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    cidr_block = "0.0.0.0/0"
    rule_no    = 100
    protocol   = -1
    action     = "allow"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.commonTags,
    tomap(
      { "Name" = "${local.commonTags.Environment}-NetworkACL" }
    )
  )
}

resource "aws_vpc_endpoint_route_table_association" "attach_internal" {
  count  = var.existing_internal_route_table_id == "" ? 1 : 0
  route_table_id  = aws_route_table.internal[0].id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "attach_public" {
  count  = var.existing_public_route_table_id == "" ? 1 : 0
  route_table_id  = aws_route_table.public[0].id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}