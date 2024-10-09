output "domain_name" {
  value = zipmap(values(aws_lb.create_lb).*.dns_name, values(aws_lb.create_lb).*.dns_name) #{ for alb in var.alb : alb.name => aws_lb.create_lb[alb.name].dns_name }
}