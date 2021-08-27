## ===== Resource for AWS RedShift parameter group ===== ##

resource "aws_redshift_parameter_group" "main" {
    name = var.paraName
    description = var.paraDesc
    family = var.paraFamily
    locals{
        parameters = [{
            name = ["value"]
            value = ["value"]
        }]
    }
    dynamic "parameter"{
        for_each = local.parameters 
        content{
            name = parameter.value.name
            value = parameter.value.value
        }
    }
  
}