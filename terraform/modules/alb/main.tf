# Create Target Group for the ALB with IP target type
resource "aws_lb_target_group" "app_target_group" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  target_type = var.target_type

  health_check {
    protocol            = var.health_check_protocol
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }
}

# ALB creation
resource "aws_lb" "alb" {
  name                       = var.alb_name
  internal                   = var.alb_internal
  load_balancer_type         = "application"
  security_groups            = var.security_groups
  subnets                    = var.public_subnets
  enable_deletion_protection = var.enable_deletion_protection

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  dynamic "subnet_mapping" {
    for_each = var.public_subnets
    content {
      subnet_id = subnet_mapping.value
    }
  }
}

# HTTP Listener for ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}
