variable "aws_region" {
  default = "eu-north-1"  # Remplacez par votre région
}

variable "ecr_repository_name" {
  default = "my-app-repo"
}

variable "ecs_cluster_name" {
  default = "my-app-cluster"
}

variable "ecs_task_family" {
  default = "my-app-task-family"
}

variable "ecs_service_name" {
  default = "my-app-service"
}

variable "subnet_ids" {
  type = list(string)
}

