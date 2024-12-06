terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "tfstate" {
  source              = "./modules/tfstate"
  tfstate_bucket_name = local.bucket_name
}

# Security Groups Module
module "security_groups" {
  source      = "./modules/sg"
  alb_sg_name = var.alb_sg_name
  app_sg_name = var.app_sg_name
}

# ALB Module
module "alb" {
  source                           = "./modules/alb"
  target_group_name                = "app-target-group"
  target_group_port                = 80
  target_group_protocol            = "HTTP"
  vpc_id                           = module.vpc.vpc_id
  target_type                      = "ip"
  health_check_path                = "/"
  health_check_protocol            = "HTTP"
  health_check_interval            = 10
  health_check_timeout             = 5
  healthy_threshold                = 3
  unhealthy_threshold              = 3
  alb_name                         = "sj-wordpress-demo-alb"
  alb_internal                     = false
  security_groups                  = [module.security_groups.alb_sg_id]
  public_subnets                   = var.public_subnets
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  listener_port                    = 80
  listener_protocol                = "HTTP"
}

# ECS IAM Module
module "ecs_iam_role" {
  source = "./modules/iam"

  role_name = "sjdemo-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

module "ecs_service" {
  source = "./modules/ecs-service"

  cluster_name          = "sj-wordpress-demo-ecs-cluster"
  task_family           = "sj-wordpress-demo-task"
  execution_role_arn    = module.ecs_iam_role.role_arn
  task_role_arn         = module.ecs_iam_role.role_arn
  task_cpu              = 1024
  task_memory           = 1024
  container_definitions = <<DEFINITION
[
  {
    "name": "sj-wordpress-demo",
    "image": "sawnjordan/wordpress-demo:ef50351",
    "cpu": 1024,
    "memory": 1024,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/wordpress",
        "awslogs-region": "aps1-az1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION

  service_name     = "sj-wordpress-demo-service"
  desired_count    = 1
  private_subnets  = module.vpc.private_subnets
  security_groups  = [module.security_groups.app_sg_id]
  target_group_arn = module.alb.target_group_arn
  container_name   = "sj-wordpress-demo"
  container_port   = 80
}

# CloudWatch Alarm for CPU Utilization (Threshold: 85%)
resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name          = "cpu-high-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [module.ecs_autoscaling.scale_up_policy_arn]
  dimensions = {
    ClusterName = module.ecs_service.ecs_cluster_name
    ServiceName = module.ecs_service.ecs_service_name
  }
}

module "ecs_autoscaling" {
  source                  = "./modules/ecs-autoscaling"
  max_capacity            = 20
  min_capacity            = 1
  resource_id             = "service/${module.ecs_service.ecs_cluster_name}/${module.ecs_service.ecs_service_name}"
  scale_up_target_value   = 85
  scale_down_target_value = 20
  scale_in_cooldown       = 300
  scale_out_cooldown      = 300
}

