
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


module "ecs_fargate" {
  source             = "./modules/ecs_fargate"
  subnet_id          = module.vpc.subnet_id
  vpc_id             = module.vpc.vpc_id
  security_group_id  = module.vpc.security_group_id

}





resource "aws_ecr_repository" "my_python_app_repo" {
  name                 = "my-python-app"
  image_tag_mutability = "MUTABLE"
  force_delete = true  
  image_scanning_configuration {
    scan_on_push = true
  }
}