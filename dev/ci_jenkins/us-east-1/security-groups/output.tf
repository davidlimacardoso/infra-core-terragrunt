output "id" {
  value = {
    elb_sg     = aws_security_group.elb_sg.id,
    jenkins_sg = aws_security_group.jenkins_sg.id,
    bastion_sg = aws_security_group.bastion_sg.id,
  }
}