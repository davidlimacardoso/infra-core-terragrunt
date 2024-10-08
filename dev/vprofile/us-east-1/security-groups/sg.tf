resource "aws_security_group" "create_sg_lb" {
  # for_each    = var.sg_ingress.vprofile-elb-sg
  name        = var.sg_ingress.vprofile-elb-sg.name
  description = var.sg_ingress.vprofile-elb-sg.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_ingress.vprofile-elb-sg.ingress
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
    Name = var.sg_ingress.vprofile-elb-sg.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "create_sg_app" {
  # for_each    = var.sg_ingress
  name        = var.sg_ingress.vprofile-app-sg.name
  description = var.sg_ingress.vprofile-app-sg.description
  vpc_id      = var.vpc_id
  depends_on  = [aws_security_group.create_sg_lb, aws_security_group.create_sg_bastion]
  dynamic "ingress" {
    for_each = var.sg_ingress.vprofile-app-sg.ingress
    content {
      description     = ingress.value.description
      protocol        = "tcp"
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = [aws_security_group.create_sg_lb.id, aws_security_group.create_sg_bastion.id] #lookup(ingress.value, "security_groups", null)
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
    Name = var.sg_ingress.vprofile-app-sg.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "create_sg_backend" {
  # for_each    = var.sg_ingress
  name        = var.sg_ingress.vprofile-backend-sg.name
  description = var.sg_ingress.vprofile-backend-sg.description
  vpc_id      = var.vpc_id
  depends_on  = [aws_security_group.create_sg_app, aws_security_group.create_sg_bastion]

  dynamic "ingress" {
    for_each = var.sg_ingress.vprofile-backend-sg.ingress
    content {
      description     = ingress.value.description
      protocol        = "tcp"
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = [aws_security_group.create_sg_app.id, aws_security_group.create_sg_bastion.id] # lookup(ingress.value, "security_groups", null)
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
    Name = var.sg_ingress.vprofile-backend-sg.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "create_sg_bastion" {
  # for_each    = var.sg_ingress.vprofile-bastion-sg
  name        = var.sg_ingress.vprofile-bastion-sg.name
  description = var.sg_ingress.vprofile-bastion-sg.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_ingress.vprofile-bastion-sg.ingress
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
    Name = var.sg_ingress.vprofile-bastion-sg.name
  }

  lifecycle {
    create_before_destroy = true
  }
}