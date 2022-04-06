terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "tls" {}
