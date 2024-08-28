<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.64.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.create_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sg_egress"></a> [sg\_egress](#input\_sg\_egress) | Allow default egress | `map` | <pre>{<br>  "cidr_blocks": [<br>    "0.0.0.0/0"<br>  ],<br>  "port": 0,<br>  "protocol": "-1"<br>}</pre> | no |
| <a name="input_sg_ingress"></a> [sg\_ingress](#input\_sg\_ingress) | Security groups ingress | <pre>map(object({<br>    name        = string<br>    description = string<br>    ingress = list(object({<br>      protocol    = string<br>      from_port   = number<br>      to_port     = number<br>      cidr_blocks = list(string)<br>      description = string<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Security group ID's |
| <a name="output_name"></a> [name](#output\_name) | Security group names |
<!-- END_TF_DOCS -->