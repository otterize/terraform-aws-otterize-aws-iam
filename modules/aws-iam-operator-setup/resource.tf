resource "aws_iam_role" "intents_operator_service_account_role" {
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${data.aws_iam_openid_connect_provider.cluster_oidc.url}"
          },
          "Action" : "sts:AssumeRoleWithWebIdentity",
          "Condition" : {
            "StringEquals" : {
              "${data.aws_iam_openid_connect_provider.cluster_oidc.url}:sub" : "system:serviceaccount:${var.otterize_deploy_namespace}:intents-operator-controller-manager"
            }
          }
        }
      ]
  })
  path = "/"
  name = substr("${var.eks_cluster_name}-otterize-intents-operator", 0, 64)
  tags = {
    "otterize/system"      = "true"
    "otterize/clusterName" = var.eks_cluster_name
  }
}

resource "aws_iam_role" "credentials_operator_service_account_role" {
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${data.aws_iam_openid_connect_provider.cluster_oidc.url}"
          },
          "Action" : "sts:AssumeRoleWithWebIdentity",
          "Condition" : {
            "StringEquals" : {
              "${data.aws_iam_openid_connect_provider.cluster_oidc.url}:sub" : "system:serviceaccount:${var.otterize_deploy_namespace}:credentials-operator-controller-manager"
            }
          }
        }
      ]
  })
  path = "/"
  name = substr("${var.eks_cluster_name}-otterize-credentials-operator", 0, 64)
  tags = {
    "otterize/system"      = "true"
    "otterize/clusterName" = var.eks_cluster_name
  }
}

resource "aws_iam_policy" "intents_operator_policy" {
  name = "${var.eks_cluster_name}-intents-operator-access-policy"
  // CF Property(Roles) = [
  //   aws_iam_role.intents_operator_service_account_role.arn
  // ]
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "iam:GetPolicy",
            "iam:GetRole",
            "iam:ListAttachedRolePolicies",
            "iam:ListEntitiesForPolicy",
            "iam:ListPolicyVersions"
          ]
          Resource = "*"
        },
        {
          Effect = "Deny"
          Action = [
            "iam:*"
          ]
          Resource = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_cluster_name}-otterize-intents-operator",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_cluster_name}-otterize-credentials-operator",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.eks_cluster_name}-limit-iam-permission-boundary"
          ]
        },
        {
          Effect = "Deny"
          Action = [
            "iam:CreatePolicyVersion",
            "iam:DeletePolicyVersion",
            "iam:DetachRolePolicy",
            "iam:SetDefaultPolicyVersion"
          ]
          Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.eks_cluster_name}-limit-iam-permission-boundary"
        },
        {
          Effect = "Deny"
          Action = [
            "iam:DeleteRolePermissionsBoundary"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "iam:AttachRolePolicy",
            "iam:CreatePolicy",
            "iam:CreatePolicyVersion",
            "iam:DeletePolicy",
            "iam:DeletePolicyVersion",
            "iam:TagPolicy",
            "iam:UntagPolicy",
            "iam:DetachRolePolicy",
            "ec2:DescribeInstances",
            "eks:DescribeCluster"
          ]
          Resource = "*"
        }
      ]
  })
}

resource "aws_iam_policy" "credentials_operator_policy" {
  name = "${var.eks_cluster_name}-credentials-operator-access-policy"
  // CF Property(Roles) = [
  //   aws_iam_role.credentials_operator_service_account_role.arn
  // ]
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "iam:GetPolicy",
            "iam:GetRole",
            "iam:ListAttachedRolePolicies",
            "iam:ListEntitiesForPolicy",
            "iam:ListPolicyVersions"
          ]
          Resource = "*"
        },
        {
          Effect = "Deny"
          Action = [
            "iam:*"
          ]
          Resource = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_cluster_name}-otterize-intents-operator",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_cluster_name}-otterize-credentials-operator",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.eks_cluster_name}-limit-iam-permission-boundary"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "iam:CreateRole"
          ]
          Resource = [
            "*"
          ]
          Condition = {
            StringEquals = {
              "iam:PermissionsBoundary" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.eks_cluster_name}-limit-iam-permission-boundary"
            }
          }
        },
        {
          Effect = "Allow"
          Action = [
            "iam:DeletePolicy",
            "iam:DeletePolicyVersion",
            "iam:DeleteRole",
            "iam:DetachRolePolicy",
            "iam:TagRole",
            "iam:TagPolicy",
            "iam:UntagRole",
            "iam:UntagPolicy",
          ]
          Resource = "*"
        },
        {
          Effect = "Deny"
          Action = [
            "iam:DeleteRolePermissionsBoundary"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "ec2:DescribeInstances",
            "eks:DescribeCluster"
          ]
          Resource = "*"
        }
      ]
  })
}

resource "awscc_iam_managed_policy" "limit_iam_permission_boundary_policy" {
  managed_policy_name = "${var.eks_cluster_name}-limit-iam-permission-boundary"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Deny"
        Action   = "iam:*"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
    }
  )
}


resource "aws_iam_role_policy_attachment" "intents_operator_policy" {
  role       = aws_iam_role.intents_operator_service_account_role.name
  policy_arn = aws_iam_policy.intents_operator_policy.arn
}

resource "aws_iam_role_policy_attachment" "credentials_operator_policy" {
  role       = aws_iam_role.credentials_operator_service_account_role.name
  policy_arn = aws_iam_policy.credentials_operator_policy.arn
}