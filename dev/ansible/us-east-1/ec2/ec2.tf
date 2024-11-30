
# # Create ec2 instance
# resource "aws_instance" "create_instance" {
#   for_each = { for idx, instance in var.instance_settings : instance.instance_name => instance }

#   ami                         = each.value.ami
#   associate_public_ip_address = each.value.associate_public_ip_address
#   instance_type               = each.value.instance_type
#   key_name                    = aws_key_pair.create_key.key_name
#   vpc_security_group_ids      = each.value.security_groups
#   subnet_id                   = each.value.subnet
#   user_data                   = each.value.user_data
#   depends_on                  = [aws_key_pair.create_key]
#   root_block_device {
#     volume_size = "20"
#     volume_type = "gp2"
#     encrypted   = true
#   }

#   tags = {
#     Name    = each.value.instance_name
#     Project = each.value.instance_name
#   }
# }


# Cria uma lista de instâncias a partir da configuração
locals {
  instances = { for instance in flatten([
    for setting in var.instance_settings : [
      for i in range(setting.instance_numbers != null ? setting.instance_numbers : 1) : {
        instance_name               = setting.instance_numbers != null ? "${setting.instance_name}-${i + 1}" : setting.instance_name
        instance_type               = setting.instance_type
        ami                         = setting.ami
        subnet                      = setting.subnet
        security_groups             = setting.security_groups
        user_data                   = setting.user_data
        associate_public_ip_address = setting.associate_public_ip_address
      }
    ]
  ]) : instance.instance_name => instance }
}

# Cria as instâncias EC2
resource "aws_instance" "create_instance" {
  for_each = local.instances

  ami                         = each.value.ami
  associate_public_ip_address = each.value.associate_public_ip_address
  instance_type               = each.value.instance_type
  key_name                    = aws_key_pair.create_key.key_name
  vpc_security_group_ids      = each.value.security_groups
  subnet_id                   = each.value.subnet
  user_data                   = each.value.user_data

  depends_on = [aws_key_pair.create_key]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true
  }

  tags = {
    Name    = each.key
    Project = each.value.instance_name
  }
}