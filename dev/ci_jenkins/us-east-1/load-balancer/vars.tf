variable "alb" {
  description = "Application Load Balancer settings"
  type = list(object({
    name              = string
    health_path       = string
    port              = number
    vpc_id            = string
    instance_id       = string
    lb_security_group = list(string)
    subnets           = list(string)
    certificate_arn   = string
  }))
}

variable "deregistration_delay" {
  type        = number
  description = "Target group deregistration delay in seconds"
  default     = 120
}

variable "health_threashold" {
  description = "Total of requests to consider the instance healthy"
  default     = 2
}

variable "unhealthy_threashold" {
  description = "Total of requests to consider the instance to stay failed"
  default     = 2
}

variable "health_interval" {
  type        = number
  description = "Interval in seconds to check the health of the instance"
  default     = 15
}

# variable "port" {
#   type        = number
#   description = "Port of the instance application"
#   default     = 8080
# }

variable "protocol" {
  type        = string
  description = "Protocol of the instance application"
  default     = "HTTP"
}

variable "env" {
  type        = string
  description = "Environment of the application"
}

