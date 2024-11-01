resource "aws_lb_target_group" "create_lb_tg" {
  for_each = { for alb in var.alb : alb.name => alb }
  name     = "${local.project_name}-${each.value.name}-tg"
  port     = var.port
  protocol = var.protocol
  vpc_id   = each.value.vpc_id

  load_balancing_algorithm_type = "round_robin"
  slow_start                    = 0
  deregistration_delay          = 60

  health_check {
    port                = var.port
    protocol            = var.protocol
    interval            = var.health_interval
    path                = each.value.health_path
    unhealthy_threshold = var.unhealthy_threashold
    healthy_threshold   = var.health_threashold
  }

}

resource "aws_lb_target_group_attachment" "create_tg_att" {
  for_each         = { for alb in var.alb : alb.name => alb }
  target_group_arn = aws_lb_target_group.create_lb_tg[each.key].arn
  target_id        = each.value.instance_id
  port             = var.port
}

resource "aws_lb" "create_lb" {
  for_each                   = { for alb in var.alb : alb.name => alb }
  name                       = "${local.project_name}-${each.value.name}-elb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = each.value.lb_security_group
  subnets                    = each.value.subnets
  enable_deletion_protection = false
}

# resource "aws_lb_listener" "https" {
#   for_each          = { for alb in var.alb : alb.name => alb }
#   load_balancer_arn = aws_lb.create_lb[each.key].arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = each.value.certificate_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.create_lb_tg[each.key].arn
#   }
# }

resource "aws_lb_listener" "http" {
  for_each          = { for alb in var.alb : alb.name => alb }
  load_balancer_arn = aws_lb.create_lb[each.key].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.create_lb_tg[each.key].arn
  }
}