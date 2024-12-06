# Input variables for the Auto Scaling Module

variable "max_capacity" {
  description = "Maximum capacity for the ECS service"
  type        = number
}

variable "min_capacity" {
  description = "Minimum capacity for the ECS service"
  type        = number
}

variable "resource_id" {
  description = "Resource ID for the ECS service"
  type        = string
}

variable "scale_up_target_value" {
  description = "Target value for CPU utilization to scale up"
  type        = number
  default     = 85
}

variable "scale_down_target_value" {
  description = "Target value for CPU utilization to scale down"
  type        = number
  default     = 20
}

variable "scale_in_cooldown" {
  description = "Cooldown period for scaling in"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Cooldown period for scaling out"
  type        = number
  default     = 300
}
