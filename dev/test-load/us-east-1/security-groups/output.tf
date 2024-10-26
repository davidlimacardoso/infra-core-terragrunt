output "id" {
  value       = zipmap(values(aws_security_group.create_sg).*.name, values(aws_security_group.create_sg).*.id)
  description = "Security group ID's"
}