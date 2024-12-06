# Create IAM Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy
}

# Attach Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = var.policy_arn
}
