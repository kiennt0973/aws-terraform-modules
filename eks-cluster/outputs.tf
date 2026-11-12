output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint for the EKS cluster."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "EKS-created security group also attached to the managed node group's network interfaces."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_version" {
  description = "Kubernetes version running on the EKS control plane."
  value       = aws_eks_cluster.this.version
}

output "node_group_arn" {
  description = "ARN of the managed node group."
  value       = aws_eks_node_group.this.arn
}

output "cluster_role_arn" {
  description = "ARN of the EKS control plane IAM role."
  value       = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  description = "ARN of the managed node group IAM role."
  value       = aws_iam_role.node_group.arn
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for service-account role trust policies."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_issuer_url" {
  description = "Cluster OIDC issuer URL."
  value       = aws_iam_openid_connect_provider.this.url
}

output "irsa_role_arns" {
  description = "IAM role names mapped to ARNs for the eks.amazonaws.com/role-arn service-account annotation."
  value       = { for name, role in module.irsa_role : name => role.role_arn }
}

output "addon_versions" {
  description = "Installed managed add-on versions keyed by add-on name."
  value = merge(
    { for name, addon in aws_eks_addon.before_compute : name => addon.addon_version },
    { for name, addon in aws_eks_addon.after_compute : name => addon.addon_version },
  )
}
