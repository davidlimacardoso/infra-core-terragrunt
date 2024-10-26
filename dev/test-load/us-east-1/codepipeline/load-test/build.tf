
resource "aws_codebuild_project" "load-test" {
  name          = local.project_name
  description   = var.description
  build_timeout = 60
  service_role  = aws_iam_role.codebuild_service_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "NO_CACHE"
  }

  build_batch_config {
    combine_artifacts = false
    service_role      = aws_iam_role.codebuild_batch_role.arn
    timeout_in_mins   = 60

    restrictions {
      compute_types_allowed = [
        "BUILD_GENERAL1_SMALL",
      ]
      maximum_builds_allowed = 100
    }
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = var.container_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = true

    environment_variable {
      name  = "auth_token"
      value = "secret/k6-dev-test-load-token:TOKEN"
      type  = "SECRETS_MANAGER"
    }
  }

  source {
    buildspec           = "aws/stg-buildspec.yml"
    type                = "CODEPIPELINE"
    git_clone_depth     = 0
    report_build_status = false
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.private_subnets
    security_group_ids = var.sg_ids
  }
}