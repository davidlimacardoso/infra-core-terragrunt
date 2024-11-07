variable "private" {
  description = "Internal domains for private IPs"

  type = object({
    name   = string
    vpc_id = optional(string)
    records = list(object({
      name    = string
      type    = string
      ttl     = number
      records = list(string)
    }))
  })

  default = {
    name    = ""
    vpc_id  = ""
    records = []
  }
}
