variable "key_pair_name" {
  type        = string
  description = "Set key pair name"
}

variable "instance_settings" {
  type = list(object({
    instance_name               = string
    instance_type               = string
    ami                         = string
    subnet                      = string
    security_groups             = list(string)
    user_data                   = optional(string)
    associate_public_ip_address = optional(bool)
  }))

  description = "Set instance settings and properties"
}