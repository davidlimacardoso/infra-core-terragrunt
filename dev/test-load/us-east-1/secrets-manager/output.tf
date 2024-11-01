output "secret" {
  description = "List of keys in the secret"
  value = {
    secret_name = "secret/${local.project_name}-${var.name}"
    keys        = var.secret_value.*.key
  }
}
