output "ami_id" {
  value = aws_ami_from_instance.create_ami.id
}

output "aws_launch_template" {
  value = aws_launch_template.create_launch_template.id
}

output "auto_scaling" {
  value = aws_autoscaling_group.create_autoscaling_group.id
}