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

module "security_groups" {
  source      = "./modules/sg"
  alb_sg_name = var.alb_sg_name
  app_sg_name = var.app_sg_name
}

# Create Target Group for the ALB with IP target type
resource "aws_lb_target_group" "app_target_group" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    path                = "/"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# ALB creation
resource "aws_lb" "alb" {
  name                       = "wordpress-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [module.security_groups.alb_sg_id]
  subnets                    = var.public_subnets
  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true

  subnet_mapping {
    subnet_id = module.vpc.public_subnets[0]
  }

  subnet_mapping {
    subnet_id = module.vpc.public_subnets[1]
  }

}

# HTTP Listener for ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

# Create IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "sjdemo-ecs-task-execution-role"
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
}

# Attach the AmazonECSTaskExecutionRolePolicy managed policy to the role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "sj-wordpress-demo-ecs-cluster"
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "wordpress-ecs-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 1024

  container_definitions = <<TASK_DEFINITION
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
        "awslogs-group": "/ecs/wordpress-ecs-task",     
        "awslogs-region": "aps1-az1",                  
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
TASK_DEFINITION

  tags = {
    Name = "wordpress-task"
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "wordpress-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [module.security_groups.app_sg_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_target_group.arn # Target Group for load balancing
    container_name   = "sj-wordpress-demo"                      # Name of the container in the task definition
    container_port   = 80                                       # Port on the container to be load balanced
  }
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
  alarm_actions       = [aws_appautoscaling_policy.scale_up_policy.arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.ecs_service.name
  }
}

# Auto Scaling Policy for Scale-Up
resource "aws_appautoscaling_policy" "scale_up_policy" {
  name               = "scale-up-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  target_tracking_scaling_policy_configuration {
    target_value = 85 # Target CPU utilization to maintain
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

# Auto Scaling Policy for Scale-Down
resource "aws_appautoscaling_policy" "scale_down_policy" {
  name               = "scale-down-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  target_tracking_scaling_policy_configuration {
    target_value = 20
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

# Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_service_autoscale" {
  max_capacity       = 20
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
