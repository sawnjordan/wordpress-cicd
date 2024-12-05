terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "tfstate" {
  source              = "./modules/tfstate"
  tfstate_bucket_name = local.bucket_name
}

module "security_groups" {
  source      = "./modules/sg"
  alb_sg_name = var.alb_sg_name
  app_sg_name = var.app_sg_name
}