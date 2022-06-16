output "arn" {
  description = "ARN of the cluster"
  value       = aws_eks_cluster.eksCluster.arn
}
output "endpoint" {
  description = "Endpoint for the cluster"
  value       = aws_eks_cluster.eksCluster.endpoint
}
output "name" {
  description = "name of the cluster"
  value       = aws_eks_cluster.eksCluster.name

}
output "version" {
  description = "platform version"
  value       = aws_eks_cluster.eksCluster.platform_version
}
output "status" {
  description = "status of the cluster"
  value       = aws_eks_cluster.eksCluster.status
}
output "tags" {
  description = "list tags associated with the cluster"
  value       = concat(aws_eks_cluster.eksCluster.*.tags_all, [""])[0]
}
output "certificate_authority" {
  description = "Kubeconfig certificate authority data"
  value       = aws_eks_cluster.eksCluster.certificate_authority[0].data
}
