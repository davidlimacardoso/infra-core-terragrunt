output "certificate" {
  value = zipmap(values(aws_acm_certificate.cert).*.domain_name, values(aws_acm_certificate.cert).*.arn)
}