variable "tfstate_bucket_name" {
  default     = "wordpress-demo-terraform-state-bucket"
  description = "Remote S3 bucket name for terraform state"
  type       = string
  validation {
    condition     = can(regex("^([a-z0-9]{1}[a-z0-9-]{1,61}[a-z0-9]{1})$", var.tfstate_bucket_name))
    error_message = "Bucket Name must not be empty and must follow S3 naming rules."
  }
}