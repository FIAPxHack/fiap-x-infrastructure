variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "fiapx-video"
}

variable "environment" {
  description = "Ambiente"
  type        = string
  default     = "dev"
}

variable "eks_node_instance_type" {
  description = "Tipo de instância dos nodes EKS"
  type        = string
  default     = "t3.small"
}

variable "eks_node_desired" {
  description = "Número desejado de nodes"
  type        = number
  default     = 2
}