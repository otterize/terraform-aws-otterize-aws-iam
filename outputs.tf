output "oidc-provider-url" {
  value = data.aws_iam_openid_connect_provider.cluster_oidc.url
}

output "otterize-credentials-operator-role-arn" {
  value = aws_iam_role.credentials_operator_service_account_role.arn
}

output "otterize-intents-operator-role-arn" {
  value = aws_iam_role.intents_operator_service_account_role.arn
}