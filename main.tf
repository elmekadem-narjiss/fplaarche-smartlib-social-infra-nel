provider "aws" {
  region = var.aws_region  # Utilisation de la variable région définie dans variables.tf
}

resource "aws_ecr_repository" "app_repo" {
  name                 = var.ecr_repository_name  # Utilisation de la variable pour le nom du dépôt
  image_tag_mutability = "MUTABLE"
  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "dev-fplarache-smartlib-service-nel-repo"
  }
}

resource "aws_ecs_cluster" "app_cluster" {
  name = var.ecs_cluster_name  # Utilisation de la variable pour le nom du cluster
  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "dev-fplarache-smartlib-service-nel-cluster"
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "prod-ecsTaskExecutionRole-narjiss"  # Ajout du préfixe "prod-" pour éviter les conflits

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
    Name        = "dev-fplarache-smartlib-service-nel-ecsTaskExecutionRole"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution.name
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = var.ecs_task_family  # Utilisation de la variable pour le nom de la famille de tâches
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "dev-fplarache-smartlib-service-nel-container"
    image     = var.ecr_repository_name  # Utilisation de la variable pour l'image du conteneur
    cpu       = 256
    memory    = 512
    essential = true
  }])

  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "dev-fplarache-smartlib-service-nel-task-definition"
  }
}

resource "aws_ecs_service" "app_service" {
  name            = var.ecs_service_name  # Utilisation de la variable pour le nom du service ECS
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  scheduling_strategy = "REPLICA"
  network_configuration {
    assign_public_ip = true
    subnets          = var.subnet_ids  # Utilisation de la variable pour les sous-réseaux
  }

  tags = {
    CreatedBy   = "narjiss"
    Environment = "Production"
    Name        = "dev-fplarache-smartlib-service-nel-service"
  }
}
