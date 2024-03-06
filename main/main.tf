module "aws_iam_operator_setup" {
  source                    = "../modules/aws-iam-operator-setup"
  eks_cluster_name          = "otterize-iam-eks-tutorial"
  otterize_deploy_namespace = "otterize-system"
}

provider "aws" {
  region = "us-west-2"
}