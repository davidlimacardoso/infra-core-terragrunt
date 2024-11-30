# Create jenkins instance security group
resource "aws_security_group" "control_sg" {
  name        = var.sg_ingress.control-server.name
  description = var.sg_ingress.control-server.description
  vpc_id      = var.vpc_id
  depends_on  = [aws_security_group.bastion_sg]
  dynamic "ingress" {
    for_each = var.sg_ingress.control-server.ingress
    content {
      description     = ingress.value.description
      protocol        = "tcp"
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = [aws_security_group.bastion_sg.id]
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
    Name = var.sg_ingress.control-server.name
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