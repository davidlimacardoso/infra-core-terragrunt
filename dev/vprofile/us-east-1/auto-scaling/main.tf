resource "aws_ami_from_instance" "create_ami" {
  name                    = "${var.name}-${formatdate("YYYYMMDDhhss", timestamp())}"
  source_instance_id      = var.ec2_instance_id
  snapshot_without_reboot = true

  tags = {
    Name = "ami-${var.name}"
  }
}

resource "aws_launch_template" "create_launch_template" {
  name                   = "lt-${var.name}-to-asg"
  image_id               = aws_ami_from_instance.create_ami.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = var.security_group

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "lt-${var.name}"
      Project = "${var.name}"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name    = "lt-${var.name}"
      Project = "${var.name}"
    }
  }

  tag_specifications {
    resource_type = "network-interface"

    tags = {
      Name    = "lt-${var.name}"
      Project = "${var.name}"
    }
  }

  iam_instance_profile {
    name = var.ec2_instance_profile
  }
}

resource "aws_autoscaling_group" "create_autoscaling_group" {
  name                      = "asg-${var.name}"
  desired_capacity          = 1
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 300

  vpc_zone_identifier = var.vpc_zone_identifier
  target_group_arns   = var.target_group_arns

  launch_template {
    id      = aws_launch_template.create_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-${var.name}"
    propagate_at_launch = true
  }
}