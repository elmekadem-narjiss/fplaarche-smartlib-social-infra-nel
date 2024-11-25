variable "aws_region" {
  default = "eu-north-1"  # Remplacez par votre région AWS désirée
}

variable "ecr_repository_name" {
  default = "dev-fplarache-smartlib-social-nel"  # Nouveau nom du dépôt avec un préfixe "dev"
}

variable "ecs_cluster_name" {
  default = "dev-fplarache-smartlib-cluster-nel"  # Nouveau nom du cluster avec un préfixe "dev"
}

variable "ecs_task_family" {
  default = "dev-fplarache-smartlib-task-family-nel"  # Nouveau nom de la famille de tâches avec un préfixe "dev"
}

variable "ecs_service_name" {
  default = "dev-fplarache-smartlib-service-nel"  # Nouveau nom du service ECS avec un préfixe "dev"
}

variable "subnet_ids" {
  type = list(string)
}
