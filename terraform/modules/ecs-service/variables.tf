variable "cluster_name" {
  description = "Name of the ECS Cluster"
  type        = string
}

variable "task_family" {
  description = "Family name for the ECS Task Definition"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 1024
}

variable "task_memory" {
  description = "Memory (MB) for the ECS task"
  type        = number
  default     = 1024
}

variable "container_definitions" {
  description = "JSON formatted container definitions for the ECS Task Definition"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS Service"
  type        = string
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "private_subnets" {
  description = "List of private subnet IDs for the ECS Service"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for the ECS Service"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "container_name" {
  description = "Name of the container in the ECS Task"
  type        = string
}

variable "container_port" {
  description = "Port of the container to expose"
  type        = number
  default     = 80
}
