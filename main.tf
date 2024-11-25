resource "aws_ecr_repository" "app_repo" {
  name                 = var.ecr_repository_name  # Utilisation de la variable mise à jour
  image_tag_mutability = "MUTABLE"

  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "${var.ecr_repository_name}-repo"  # Mise à jour du nom avec la variable
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags] # Ignore les changements sur les tags
  }
}

resource "aws_ecs_cluster" "app_cluster" {
  name = var.ecs_cluster_name  # Utilisation de la variable ECS cluster

  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "${var.ecs_cluster_name}-cluster"  # Mise à jour avec la variable
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags] # Ignore les changements sur les tags
  }
}

resource "aws_ecs_task_definition" "app_task" {
  family                = var.ecs_task_family  # Utilisation de la variable ECS task family
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
    Name        = "${var.ecs_task_family}-task-definition"  # Mise à jour avec la variable
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [container_definitions, tags] # Ignore les changements sur les tags et container_definitions
  }
}

resource "aws_ecs_service" "app_service" {
  name            = var.ecs_service_name  # Utilisation de la variable ECS service name
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
    Name        = "${var.ecs_service_name}-service"  # Mise à jour avec la variable
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags] # Ignore les changements sur les tags
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole-narjiss"  # Nom de rôle ECS spécifique

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
    Name        = "ecsTaskExecutionRole-narjiss"  # Mise à jour avec le nom du rôle
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
