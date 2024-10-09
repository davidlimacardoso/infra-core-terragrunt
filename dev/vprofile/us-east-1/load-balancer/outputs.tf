output "domain_name" {
  value = {
    for alb in var.alb : alb.name => {
      dns_name = aws_lb.create_lb[alb.name].dns_name
      arn      = aws_lb.create_lb[alb.name].arn
    }
  }
}