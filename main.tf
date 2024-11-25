resource "aws_ecr_repository" "app_repo" {
  name                 = "my-app-repo-narjiss"
  image_tag_mutability = "MUTABLE"

  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "my-app-repo-narjiss-repo"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags] # Ignore les changements sur les tags
  }
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "my-app-cluster-narjiss"

  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "my-app-cluster-narjiss-cluster"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags] # Ignore les changements sur les tags
  }
}

resource "aws_ecs_task_definition" "app_task" {
  family                = "my-app-task-family-narjiss"
  container_definitions = <<DEFINITION
[{
    "name": "app",
    "image": "${aws_ecr_repository.app_repo.repository_url}:latest",
    "memory": 512,
    "cpu": 256,
    "essential": true
}]
DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "my-app-task-family-narjiss-task-definition"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [container_definitions, tags] # Ignore les changements sur les tags et container_definitions
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "my-app-service-narjiss"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
  }

  desired_count = 1

  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "my-app-service-narjiss-service"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags] # Ignore les changements sur les tags
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole-narjiss"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
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
    Name        = "ecsTaskExecutionRole-narjiss"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags] # Ignore les changements sur les tags
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
