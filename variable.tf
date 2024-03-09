variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "otterize_deploy_namespace" {
  description = "The namespace Otterize is deployed in."
  type        = string
  default     = "otterize-system"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}
