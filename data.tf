data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_vpc" "selected" {
  default = var.vpc_use_default
  id      = var.vpc_id
}

data "aws_subnets" "vault" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  dynamic "filter" {
    for_each = tomap(var.vault_subnet_tag)
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}

data "aws_subnets" "nlb" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  dynamic "filter" {
    for_each = tomap(local.nlb_subnet_tag)
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}

data "aws_ssm_parameter" "amazon_linux_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_kms_key" "ebs" {
  key_id = "alias/aws/ebs"
}
