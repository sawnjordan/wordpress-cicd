variable "aws_region" {
  default     = "ap-south-1"
  description = "aws region"
}
variable "vps_name" {
  default     = "wordpress-demo-vpc"
  description = "VPC name"
}
variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "default CIDR range of the VPC"
}
variable "azs" {
  default     = ["aps1-az1", "aps1-az2"]
  description = "aws azs"
}
variable "public_subnets" {
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "Public Subnets"
}
variable "private_subnets" {
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.20.0/24", "10.0.21.0/24"]
  description = "Private Subnets"
}
variable "alb_sg_name" {
  description = "Name of the ALB Security Group"
  type        = string
  default     = "alb-sg"
}

variable "app_sg_name" {
  description = "Name of the Application Security Group"
  type        = string
  default     = "app-sg"
}
