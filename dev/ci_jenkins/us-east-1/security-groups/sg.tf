# Create jenkins instance security group
resource "aws_security_group" "jenkins_sg" {
  name        = var.sg_ingress.jenkins-server.name
  description = var.sg_ingress.jenkins-server.description
  vpc_id      = var.vpc_id
  depends_on  = [aws_security_group.elb_sg, aws_security_group.bastion_sg]
  dynamic "ingress" {
    for_each = var.sg_ingress.jenkins-server.ingress
    content {
      description     = ingress.value.description
      protocol        = "tcp"
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = [aws_security_group.elb_sg.id, aws_security_group.bastion_sg.id]
      prefix_list_ids = lookup(ingress.value, "prefix_list_ids", null)
    }
  }

  egress {
    protocol    = "-1"
    from_port   = var.sg_egress.port
    to_port     = var.sg_egress.port
    cidr_blocks = var.sg_egress.cidr_blocks
  }

  tags = {
    Name = var.sg_ingress.jenkins-server.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create bastion security group
resource "aws_security_group" "bastion_sg" {
  name        = var.sg_ingress.bastion-sg.name
  description = var.sg_ingress.bastion-sg.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_ingress.bastion-sg.ingress
    content {
      description     = ingress.value.description
      protocol        = "tcp"
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      prefix_list_ids = lookup(ingress.value, "prefix_list_ids", null)
    }
  }

  egress {
    protocol    = "-1"
    from_port   = var.sg_egress.port
    to_port     = var.sg_egress.port
    cidr_blocks = var.sg_egress.cidr_blocks
  }

  tags = {
    Name = var.sg_ingress.bastion-sg.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create load balancer security group 
resource "aws_security_group" "elb_sg" {
  name        = var.sg_ingress.jenkins-elb-sg.name
  description = var.sg_ingress.jenkins-elb-sg.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_ingress.jenkins-elb-sg.ingress
    content {
      description     = ingress.value.description
      protocol        = "tcp"
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      prefix_list_ids = lookup(ingress.value, "prefix_list_ids", null)
    }
  }

  egress {
    protocol    = "-1"
    from_port   = var.sg_egress.port
    to_port     = var.sg_egress.port
    cidr_blocks = var.sg_egress.cidr_blocks
  }

  tags = {
    Name = var.sg_ingress.jenkins-elb-sg.name
  }

  lifecycle {
    create_before_destroy = true
  }
}