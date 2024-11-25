provider "aws" {
  region = "eu-north-1"  # Update to your desired AWS region
}

resource "aws_ecr_repository" "app_repo" {
  name                 = "my-app-repo-social-nel"
  image_tag_mutability = "MUTABLE"
  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "my-app-repo-social-nel-repo"
  }
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "my-app-cluster-narjiss"
  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "my-app-cluster-narjiss-cluster"
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "prod-ecsTaskExecutionRole-narjiss"  # Adding "prod-" as a prefix to avoid conflicts

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "prod-ecsTaskExecutionRole-narjiss"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution.name
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "my-app-task-family-narjiss"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "my-app-container"
    image     = "my-app-repo-social-nel"
    cpu       = 256
    memory    = 512
    essential = true
  }])

  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "my-app-task-family-narjiss-task-definition"
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "my-app-service-narjiss"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  scheduling_strategy = "REPLICA"
  network_configuration {
    assign_public_ip = true
    subnets          = ["subnet-09f87781e43dd92fa", "subnet-0ecad11178a197a0b"]
  }

  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "my-app-service-narjiss-service"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app_repo.repository_url
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.app_cluster.id
}
