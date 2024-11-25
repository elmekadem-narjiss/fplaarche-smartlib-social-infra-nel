variable "aws_region" {
  default = "eu-north-1"  # Remplacez par votre région
}

variable "ecr_repository_name" {
  default = "my-app-repo-social-nel"  # Nouveau nom du dépôt
}

variable "ecs_cluster_name" {
  default = "my-app-cluster-narjiss"  # Ajouter 'narjiss' au nom du cluster
}

variable "ecs_task_family" {
  default = "my-app-task-family-narjiss"  # Ajouter 'narjiss' au nom de la famille de tâches
}

variable "ecs_service_name" {
  default = "my-app-service-narjiss"  # Ajouter 'narjiss' au nom du service ECS
}

variable "subnet_ids" {
  type = list(string)
}
