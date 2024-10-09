output "private_hosted_zone_id" {
  value = zipmap(values(aws_route53_zone.private).*.name, values(aws_route53_zone.private).*.id)
}