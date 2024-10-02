locals {

  #profile = get_env("AWS_PROFILE")

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  # Extract the variables we need for easy access
  environment = local.environment_vars.locals.environment
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region
}

terraform {
  extra_arguments "custom_vars" {
    commands = ["init", "plan", "apply"]

    env_vars = {
      TF_PLUGIN_CACHE_DIR="${get_repo_root()}"
      TERRAGRUNT_FETCH_DEPENDENCY_OUTPUT_FROM_STATE=true
    }
  }
  
  // before_hook "terraform_fmt" {
  //   commands     = ["apply", "plan"]
  //   execute      = ["sh", "-c", "cd ${get_terragrunt_dir()} && terraform fmt"]
  //   run_on_error = true
  // }

  // before_hook "terragrunt_fmt" {
  //   commands     = ["apply", "plan"]
  //   execute      = ["sh", "-c", "cd ${get_terragrunt_dir()} && terragrunt hclfmt"]
  //   run_on_error = true
  // }

  // before_hook "terraform_docs_readme" {
  //   commands     = ["apply", "plan"]
  //   execute      = ["sh", "-c", "terraform-docs markdown table --output-file README.md --output-mode inject . && cp -r README.md ${get_terragrunt_dir()}"]
  //   run_on_error = true
  // }
}

generate "provider" {
  path      = "auto_provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.aws_region}"
      allowed_account_ids = ["${local.account_id}"]
      default_tags {
        tags = {
          Terraform_managed = "true"
          Project           = "Infra - Core"
          env_account       = "${local.environment}"
        }
      }
    }
  EOF
}


remote_state {
  backend = "s3"

  config = {
    bucket = "infra-core-terragrunt-${local.account_id}"
    # key    = "${path_relative_to_include()}/terraform.tfstate"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    # key    = "${get_path_from_repo_root()}/terraform.tfstate"


    
    region = "us-east-1"
    # assume_role = {
    #   role_arn = "arn:aws:iam::xxxxxxxxx:role/dev-test-terragrunt"
    # }
    encrypt = true

  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
