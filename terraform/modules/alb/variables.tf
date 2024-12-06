variable "target_group_name" {
  description = "Name of the Target Group"
  type        = string
}

variable "target_group_port" {
  description = "Port for the Target Group"
  type        = number
  default = 80
}

variable "target_group_protocol" {
  description = "Protocol for the Target Group"
  type        = string
  default     = "HTTP"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "target_type" {
  description = "Target type for the Target Group"
  type        = string
  default     = "ip"
}

# Health Check Variables
variable "health_check_protocol" {
  description = "Protocol for Health Check"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "Path for Health Check"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Interval for Health Check"
  type        = number
  default     = 10
}

variable "health_check_timeout" {
  description = "Timeout for Health Check"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Healthy Threshold for Health Check"
  type        = number
  default     = 3
}

variable "unhealthy_threshold" {
  description = "Unhealthy Threshold for Health Check"
  type        = number
  default     = 3
}

# ALB Variables
variable "alb_name" {
  description = "Name of the ALB"
  type        = string
}

variable "alb_internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "Security Groups for the ALB"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnets for the ALB"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

# Listener Variables
variable "listener_port" {
  description = "Port for the Listener"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocol for the Listener"
  type        = string
  default     = "HTTP"
}
