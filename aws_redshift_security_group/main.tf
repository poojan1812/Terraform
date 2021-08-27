## ===== Resource for AWS Redshift Security group ===== ##
resource "aws_redshift_security_group" "main" {
  name        = var.secName
  description = var.secDesc
  locals {
    ingressRules = [{
      cidr                    = ["value"]
      security_group_name     = ["value"]
      security_group_owner_id = ["value"]
    }]
  }
  dynamic "ingress" {
    for_each = local.ingressRules
    content {
      cidr                    = ingress.value.cidr
      security_group_name     = ingress.value.cidr
      security_group_owner_ir = ingress.value.dir
    }

  }

}
