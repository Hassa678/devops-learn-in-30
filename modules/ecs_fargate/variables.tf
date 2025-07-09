variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "vpc_id" {
  description = "VPC ID for ECS task"
  type        = string
}