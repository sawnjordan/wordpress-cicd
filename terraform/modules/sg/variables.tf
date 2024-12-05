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
