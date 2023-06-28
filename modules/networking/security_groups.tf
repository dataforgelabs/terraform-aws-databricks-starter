resource "aws_security_group" "main" {
  name        = "${local.commonTags.Environment}-Databricks-${local.commonTags.Client}"
  description = "Databricks Workspace Security Group"
  vpc_id      = var.existing_vpc_id == "" ? aws_vpc.main[0].id : var.existing_vpc_id

  ingress = [
    {
      from_port        = 0
      to_port          = 65535
      protocol         = "tcp"
      self             = true
      description      = "Databricks allow TCP on all ports when traffic source uses the same security group"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
    },
    {
      from_port        = 0
      to_port          = 65535
      protocol         = "udp"
      self             = true
      description      = "Databricks allow UDP on all ports when traffic source uses the same security group"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.commonTags,
    tomap(
      { "Name" = "${local.commonTags.Environment}-Databricks-${local.commonTags.Client}",
      "Application" = "Databricks" }
    )
  )
}