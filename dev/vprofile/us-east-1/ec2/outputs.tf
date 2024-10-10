
output "ec2_instance" {
  value = { for k, instance in aws_instance.create_instance : k => instance.id }
}

output "key_pair_name" {
  value = aws_key_pair.create_key.key_name
}

output "iam_instance_profile" {
  value = zipmap(values(aws_iam_instance_profile.ec2_instance_profile).*.name, values(aws_iam_instance_profile.ec2_instance_profile).*.arn)
}
