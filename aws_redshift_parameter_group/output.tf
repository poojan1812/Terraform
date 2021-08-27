output "paraArn" {
  description = "ARN for the parameter group"
  value       = aws_redshift_parameter_group.main.arn

}
output "paraId" {
  description = "Name of the parameter group"
  value       = aws_redshift_parameter_group.main.id

}
