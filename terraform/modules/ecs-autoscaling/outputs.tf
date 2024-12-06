# Outputs for the Auto Scaling Module

output "scale_up_policy_arn" {
  description = "ARN of the scale-up policy"
  value       = aws_appautoscaling_policy.scale_up_policy.arn
}

output "scale_down_policy_arn" {
  description = "ARN of the scale-down policy"
  value       = aws_appautoscaling_policy.scale_down_policy.arn
}
