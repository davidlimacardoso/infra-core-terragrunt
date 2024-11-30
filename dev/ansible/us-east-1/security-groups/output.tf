output "id" {
  value = {
    control_sg = aws_security_group.control_sg.id,
    bastion_sg = aws_security_group.bastion_sg.id
  }
}
