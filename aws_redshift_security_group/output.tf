output "secId" {
    description = "ID of the redshift security group"
    value = aws_redshift_security_group.main.id
  
}