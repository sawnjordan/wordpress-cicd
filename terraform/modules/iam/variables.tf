variable "role_name" {
  description = "Name of the IAM Role"
  type        = string
}

variable "assume_role_policy" {
  description = "JSON-encoded Assume Role Policy for the IAM Role"
  type        = string
}

variable "policy_arn" {
  description = "ARN of the IAM Policy to attach to the role"
  type        = string
}
