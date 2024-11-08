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
      security_groups = ingress.value.from_port != 22 ? [aws_security_group.elb_sg.id] : [aws_security_group.bastion_sg.id]
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

# Create nexus instance security group
resource "aws_security_group" "nexus_sg" {
  name        = var.sg_ingress.nexus-sg.name
  description = var.sg_ingress.nexus-sg.description
  vpc_id      = var.vpc_id
  depends_on  = [aws_security_group.nexus_elb_sg, aws_security_group.bastion_sg]
  dynamic "ingress" {
    for_each = var.sg_ingress.nexus-sg.ingress
    content {
      description     = ingress.value.description
      protocol        = "tcp"
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = ingress.value.from_port != 22 ? [aws_security_group.nexus_elb_sg.id] : [aws_security_group.bastion_sg.id]
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
    Name = var.sg_ingress.nexus-sg.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create nexus load balancer security group 
resource "aws_security_group" "nexus_elb_sg" {
  name        = var.sg_ingress.nexus-elb-sg.name
  description = var.sg_ingress.nexus-elb-sg.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_ingress.nexus-elb-sg.ingress
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
    Name = var.sg_ingress.nexus-elb-sg.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create Sonar instance security group
resource "aws_security_group" "sonar_sg" {
  name        = var.sg_ingress.sonar-sg.name
  description = var.sg_ingress.sonar-sg.description
  vpc_id      = var.vpc_id
  depends_on  = [aws_security_group.sonar_elb_sg, aws_security_group.bastion_sg]
  dynamic "ingress" {
    for_each = var.sg_ingress.sonar-sg.ingress
    content {
      description     = ingress.value.description
      protocol        = "tcp"
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = ingress.value.from_port != 22 ? [aws_security_group.sonar_elb_sg.id] : [aws_security_group.bastion_sg.id]
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
    Name = var.sg_ingress.sonar-sg.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create Sonar load balancer security group 
resource "aws_security_group" "sonar_elb_sg" {
  name        = var.sg_ingress.sonar-elb-sg.name
  description = var.sg_ingress.sonar-elb-sg.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_ingress.sonar-elb-sg.ingress
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
    Name = var.sg_ingress.sonar-elb-sg.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "jenkins_from_sonar" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sonar_sg.id
  security_group_id        = aws_security_group.jenkins_sg.id
  description              = "Allow traffic from Sonar to Jenkins on port 8080"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group_rule" "sonar_from_jenkins" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jenkins_sg.id
  security_group_id        = aws_security_group.sonar_sg.id
  description              = "Allow traffic from sonar to Jenkins on port 80"


  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group_rule" "nexus_from_jenkins" {
  type                     = "ingress"
  from_port                = 8081
  to_port                  = 8081
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.jenkins_sg.id
  security_group_id        = aws_security_group.nexus_sg.id
  description              = "Allow traffic from Nexus to Jenkins on port 8081"


  lifecycle {
    create_before_destroy = true
  }

}