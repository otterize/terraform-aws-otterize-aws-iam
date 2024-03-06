output "cluster_oidcurl" {
  description = "The OpenID Connect URL (without protocol)"
  value = aws_msk_cluster_policy.cluster_oidcurl.id
}

output "cluster_oidc_provider" {
  description = "The ARN of the OIDCProvider"
  value = aws_ecs_cluster_capacity_providers.cluster_oidc_provider.id
}

