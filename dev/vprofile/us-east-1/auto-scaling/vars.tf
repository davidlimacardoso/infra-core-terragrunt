variable "ec2_instance_id" {
  type        = string
  description = "EC2 instance id for autoscaling"
}

variable "name" {
  type        = string
  description = "Name used to create AMI, Launch template and Auto Scaling"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "key_pair_name" {
  type        = string
  description = "Key pair name"
  default     = ""
}

variable "security_group" {
  type        = list(string)
  description = "Security groups instance associated"
  default     = []
}

variable "ec2_instance_profile" {
  type        = string
  description = "EC2 instance profile arn"
  default     = ""
}

variable "vpc_zone_identifier" {
  type        = list(string)
  description = "Subnet ids"
}

variable "target_group_arns" {
  type        = list(string)
  description = "List of target groups"
}