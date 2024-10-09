
# Create ec2 instance
resource "aws_instance" "create_instance" {
  for_each = { for idx, instance in var.instance_settings : instance.instance_name => instance }

  ami                         = each.value.ami
  associate_public_ip_address = each.value.associate_public_ip_address
  instance_type               = each.value.instance_type
  key_name                    = aws_key_pair.create_key.key_name
  vpc_security_group_ids      = each.value.security_groups
  subnet_id                   = each.value.subnet
  user_data                   = each.value.user_data
  iam_instance_profile        = try(aws_iam_instance_profile.ec2_instance_profile[each.key].name, null)
  depends_on                  = [aws_key_pair.create_key]
  root_block_device {
    volume_size = "20"
    volume_type = "gp2"
    encrypted   = true
  }

  tags = {
    Name = each.value.instance_name
  }
}

# Create IAM role for EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  for_each = { for idx, instance in var.instance_settings : instance.instance_name => instance if instance.iam_role != null }
  name     = "ec2-instance-profile-${each.value.instance_name}"
  role     = each.value.iam_role

  tags = {
    Name = each.value.instance_name
  }
}