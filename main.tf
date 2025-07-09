
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
    bucket         = "hassan-terraform-state-2025"
    key            = "dev/infra/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks-2025"
  }
}


provider "aws" {
  region = "us-west-2"
}


module "vpc" {
  source = "./modules/vpc"
}


module "ec2_instance" {
  source            = "./modules/ec2_instance"
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.vpc.security_group_id
}


resource "aws_ecr_repository" "my_python_app_repo" {
  name                 = "my-python-app"
  image_tag_mutability = "MUTABLE"
  force_delete = true  
  image_scanning_configuration {
    scan_on_push = true
  }
}