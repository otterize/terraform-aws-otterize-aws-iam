variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "otterize-iam-eks-tutorial"
}

variable "otterize_deploy_namespace" {
  description = "The namespace Otterize is deployed in."
  type        = string
  default     = "otterize-system"
}

