data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id   = data.aws_caller_identity.current.account_id
  region       = data.aws_region.current.name
  project_name = "${var.project}-${var.env}-${var.name}"
}

variable "container_image" {
  description = "Docker or ECR image"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "sg_ids" {
  description = "Security Group"
  type        = list(string)
}

variable "description" {
  description = "Description"
  type        = string
}

variable "name" {
  description = "Name of codebuild project"
  type        = string
}

variable "git_connection" {
  description = "AWS connection with Git dev tools"
  type        = string
}

variable "git_repository" {
  description = "GitHub repository"
  type        = string
}

variable "git_branch" {
  description = "GitHub branch"
  type        = string
}


variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "s3_artifact_bucket" {
  description = "S3 bucket for artifacts"
  type        = string
}

variable "s3_codepipeline_bucket" {
  description = "S3 bucket key for codepipeline"
  type        = string
}

variable "buildspec" {
  description = "Buildspec file path"
  type        = string
}

variable "asm_keys" {

  description = "List of Secrets Manager keys"
  type = object({
    keys        = list(string)
    secret_name = string
  })
  default = {
    keys        = []
    secret_name = ""
  }
}