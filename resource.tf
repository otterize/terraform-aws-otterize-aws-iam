resource "aws_iam_policy" "limit_iam_permission_boundary_policy" {
  name = "${var.eks_cluster_name}-limit-iam-permission-boundary"
  policy = jsonencode({
    Statement = [
      {
        Effect = "Deny"
        Action = ["iam:*"]
        Resource = "*"
      },
      {
        Effect = ["Allow"]
        Action = ["*"]
        Resource = "*"
      }
    ]
  })
}

condition {
  test = "StringEquals"
  variable = "iam:PermissionsBoundary"
  values = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.eks_cluster_name}-limit-iam-permission-boundary"]
}


resource "aws_iam_role" "intents_operator_service_account_role" {
  assume_role_policy = "{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${aws_msk_cluster_policy.cluster_oidcurl.id}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${aws_msk_cluster_policy.cluster_oidcurl.id}:sub": "system:serviceaccount:${var.otterize_deploy_namespace}:intents-operator-controller-manager"
        }
      }
    }
  ]
}"
  path = "/"
  name = "${var.eks_cluster_name}-otterize-intents-operator"
  tags = {
    otterize/system = "true"
    otterize/clusterName = "${var.eks_cluster_name}"
  }
}

resource "aws_iam_role" "credentials_operator_service_account_role" {
  assume_role_policy = "{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${aws_msk_cluster_policy.cluster_oidcurl.id}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${aws_msk_cluster_policy.cluster_oidcurl.id}:sub": "system:serviceaccount:${var.otterize_deploy_namespace}:credentials-operator-controller-manager"
        }
      }
    }
  ]
}"
  path = "/"
  name = "${var.eks_cluster_name}-otterize-credentials-operator"
  tags = {
    otterize/system = "true"
    otterize/clusterName = "${var.eks_cluster_name}"
  }
}

resource "aws_iam_policy" "intents_operator_policy" {
  name = "${var.eks_cluster_name}-intents-operator-access-policy"
  // CF Property(Roles) = [
  //   aws_iam_role.intents_operator_service_account_role.arn
  // ]
  policy = {
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
          "iam:DetachRolePolicy",
          "ec2:DescribeInstances",
          "eks:DescribeCluster",
          "organizations:DescribeAccount",
          "organizations:DescribeOrganization",
          "organizations:DescribeOrganizationalUnit",
          "organizations:DescribePolicy",
          "organizations:ListChildren",
          "organizations:ListParents",
          "organizations:ListPolicies",
          "organizations:ListPoliciesForTarget",
          "organizations:ListRoots",
          "organizations:ListTargetsForPolicy"
        ]
        Resource = "*"
      }
    ]
  }
}

resource "aws_iam_policy" "credentials_operator_policy" {
  name = "${var.eks_cluster_name}-credentials-operator-access-policy"
  // CF Property(Roles) = [
  //   aws_iam_role.credentials_operator_service_account_role.arn
  // ]
  policy = {
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
            iam:PermissionsBoundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.eks_cluster_name}-limit-iam-permission-boundary"
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
          "iam:TagRole"
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
          "eks:DescribeCluster",
          "organizations:DescribeAccount",
          "organizations:DescribeOrganization",
          "organizations:DescribeOrganizationalUnit",
          "organizations:DescribePolicy",
          "organizations:ListChildren",
          "organizations:ListParents",
          "organizations:ListPolicies",
          "organizations:ListPoliciesForTarget",
          "organizations:ListRoots",
          "organizations:ListTargetsForPolicy"
        ]
        Resource = "*"
      }
    ]
  }
}

resource "aws_emr_managed_scaling_policy" "limit_iam_permission_boundary_policy" {
  // CF Property(ManagedPolicyName) = "${var.eks_cluster_name}-limit-iam-permission-boundary"
  // CF Property(PolicyDocument) = {
  //   Version = "2012-10-17"
  //   Statement = [
  //     {
  //       Effect = "Deny"
  //       Action = "iam:*"
  //       Resource = "*"
  //     },
  //     {
  //       Effect = "Allow"
  //       Action = "*"
  //       Resource = "*"
  //     }
  //   ]
  // }
}

resource "aws_msk_cluster_policy" "cluster_oidcurl" {
  // CF Property(ServiceToken) = aws_lambda_function.cluster_oidcurl_function.arn
  // CF Property(ClusterName) = var.eks_cluster_name
}

resource "aws_lambda_function" "cluster_oidcurl_function" {
  runtime = "python3.7"
  handler = "index.lambda_handler"
  memory_size = 128
  role = aws_iam_role.cluster_oidc_lambda_execution_role.arn
  timeout = 30
  code_signing_config_arn = {
    ZipFile = "import boto3
import json
import cfnresponse
eks = boto3.client("eks")
def lambda_handler(event, context):
  responseData = {}
  if event['RequestType'] == 'Delete':
    responseData['Reason'] = "Success"
    cfnresponse.send(event, context, cfnresponse.SUCCESS, responseData, "")
  else:
    try:
      cluster_name = event['ResourceProperties']['ClusterName']
      response = eks.describe_cluster(name=cluster_name)
      cluster_oidc_url = response['cluster']['identity']['oidc']['issuer']
      # We need the url for the roles without the protocol when creating roles, so remove
      # it here to make this easier to use in CF templates.
      without_protocol = cluster_oidc_url.replace('https://', '')
      responseData['Reason'] = "Success"
      responseData['Url'] = without_protocol
      cfnresponse.send(event, context, cfnresponse.SUCCESS, responseData, without_protocol)
    except Exception as e:
      responseData['Reason'] = str(e)
      cfnresponse.send(event, context, cfnresponse.FAILED, responseData, "")
"
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_oidc_provider" {
  // CF Property(ServiceToken) = aws_lambda_function.cluster_oidc_provider_function.arn
  // CF Property(ClusterOIDCURL) = aws_msk_cluster_policy.cluster_oidcurl.id
}

resource "aws_lambda_function" "cluster_oidc_provider_function" {
  runtime = "python3.7"
  handler = "index.lambda_handler"
  memory_size = 128
  role = aws_iam_role.cluster_oidc_lambda_execution_role.arn
  timeout = 30
  code_signing_config_arn = {
    ZipFile = "import boto3
from botocore.exceptions import ClientError
import json
import cfnresponse
iam = boto3.client("iam")
def lambda_handler(event, context):
  data = {}
  try:
    cluster_oidc_url = event['ResourceProperties']['ClusterOIDCURL']
    if event['RequestType'] == 'Create':
      with_protocol = "https://" + cluster_oidc_url
      # This is the ca thumbprint of AWS's issuer
      issuer_thumbprint = '9e99a48a9960b14926bb7f3b02e22da2b0ab7280'
      try:
        print("target ARN:" + 'arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/' + cluster_oidc_url)
        iam.get_open_id_connect_provider(OpenIDConnectProviderArn='arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/' + cluster_oidc_url)
      except iam.exceptions.NoSuchEntityException:
        resp = iam.create_open_id_connect_provider(Url=with_protocol,ClientIDList=['sts.amazonaws.com'],ThumbprintList=[issuer_thumbprint])
        provider_arn = resp['OpenIDConnectProviderArn']
        data["Reason"] = "Provider with ARN " + provider_arn + " created"
        cfnresponse.send(event, context, cfnresponse.SUCCESS, data, provider_arn)
        return

      data["Reason"] = "Provider already existed, not created"
      cfnresponse.send(event, context, cfnresponse.SUCCESS, data, None)
    elif event['RequestType'] == 'Delete':
      provider_arn = event["PhysicalResourceId"]
      print("Getting ready to delete provider " + provider_arn)
      if provider_arn is None or not provider_arn.startswith("arn:aws"):
        data["Reason"] = "Provider was not created, not removing"
        cfnresponse.send(event, context, cfnresponse.SUCCESS, data, provider_arn)
      else:
        resp = iam.delete_open_id_connect_provider(OpenIDConnectProviderArn=provider_arn)
        data["Reason"] = "Provider with ARN " + provider_arn + " deleted"
        cfnresponse.send(event, context, cfnresponse.SUCCESS, data, provider_arn)
    else:
      data["Reason"] = "Unknown operation: " + event['RequestType']
      cfnresponse.send(event, context, cfnresponse.FAILED, data, "")
  except Exception as e:
    data["Reason"] = "Cannot " + event['RequestType'] + " Provider" + str(e)
    cfnresponse.send(event, context, cfnresponse.FAILED, data, "")
"
  }
}

resource "aws_iam_role" "cluster_oidc_lambda_execution_role" {
  path = "/"
  assume_role_policy = {
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com"
          ]
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  }
  force_detach_policies = [
    {
      PolicyName = "oidc-provider-management"
      PolicyDocument = {
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "eks:DescribeCluster"
            ]
            Resource = "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name}"
          },
          {
            Effect = "Allow"
            Action = [
              "iam:*OpenIDConnectProvider*"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ]
            Resource = "*"
          }
        ]
      }
    }
  ]
}