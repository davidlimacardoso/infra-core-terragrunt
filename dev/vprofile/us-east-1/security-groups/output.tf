output "id" {
  value = {
    vprofile-elb-sg     = aws_security_group.create_sg_lb.id,
    vprofile-app-sg     = aws_security_group.create_sg_app.id,
    vprofile-backend-sg = aws_security_group.create_sg_backend.id,
    vprofile-bastion-sg = aws_security_group.create_sg_bastion.id,
  }
}
