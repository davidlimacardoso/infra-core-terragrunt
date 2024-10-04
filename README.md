## Stack
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white) 
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
<br>
[![Maintained by Gruntwork.io](https://img.shields.io/badge/maintained%20by-gruntwork.io-%235849a6.svg)](https://gruntwork.io/?ref=repo_terragrunt)


# AWS Infrastructure as Code with Terraform about Terragrunt wrapper

This repository contains my Terraform configurations for managing my AWS infrastructure, including EC2 instances, IAM roles, Route 53 records, ACM certificates and much more...

## Overview

This project uses Terraform to provision and manage various AWS resources in a modular and scalable way. It's designed to work with Terragrunt for managing multiple environments and reducing code duplication.

## Key Components

### terragrunt.hcl

```hcl
locals {
  # You can to use AWS profile enviroment 
  #profile = get_env("AWS_PROFILE")

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  # Extract the variables we need for easy access
  environment = local.environment_vars.locals.environment
  account_id  = local.account_vars.locals.aws_account_id
  aws_region  = local.region_vars.locals.aws_region
}

terraform {
  extra_arguments "custom_vars" {
    commands = ["init", "plan", "apply"]

    #Auto setting environments on init 
    env_vars = {
      
      # setting terragrunt caching on root directory
      TF_PLUGIN_CACHE_DIR                           = "${get_repo_root()}"
      
      # Setting that affects how Terragrunt handles dependencies between modules
      TERRAGRUNT_FETCH_DEPENDENCY_OUTPUT_FROM_STATE = true
    }
  }

  # Now ou can setting hooks to execute shell commands... 
  # Setting hooks to format code before plan and apply terraform files
  before_hook "terraform_fmt" {
    commands     = ["apply", "plan"]
    execute      = ["sh", "-c", "cd ${get_terragrunt_dir()} && terraform fmt"]
    run_on_error = true
  }

  # Setting Hooks to format code before plan and apply terragrunt files
  before_hook "terragrunt_fmt" {
    commands     = ["apply", "plan"]
    execute      = ["sh", "-c", "cd ${get_terragrunt_dir()} && terragrunt hclfmt"]
    run_on_error = true
  }

  # Setting Hooks to make terraform-docs before plan and apply
  before_hook "terraform_docs_readme" {
    commands     = ["apply", "plan"]
    execute      = ["sh", "-c", "terraform-docs markdown table --output-file README.md --output-mode inject . && cp -r README.md ${get_terragrunt_dir()}"]
    run_on_error = true
  }
}

# Configure the AWS provider, using the standard configuration and tags
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

# Configure the remote state S3 bucket, key and generate terragrunt backend
remote_state {
  backend = "s3"

  config = {
    bucket = "infra-core-terragrunt-${local.account_id}"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region = "us-east-1"
    # assume_role = {
    #   role_arn = "arn:aws:iam::xxxxxxxxx:role/role_to_be_assumed"
    # }
    encrypt = true
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

```

## Usage

1. Ensure you have Terraform and AWS CLI installed and configured.
2. Clone this repository.
3. Navigate to the desired module directory.
4. The `./dev` directory is a environment model, you can rename or copy to other enviroment.
5. The directory `./dev/jupter` is a AWS account name, may be a project name too.
6. Set your AWS account ID inside `./dev/jupter/account.hcl`
7. Initialize Terragrunt:

8. Plan your changes:
```
terragrunt plan
```
9. Apply the changes:
```
terragrunt apply
```

## Modules Terraform

Modules are this repository [``infra-core-terraform-modules``](https://github.com/davidlimacardoso/infra-core-terraform-modules). You can use this module to create resources.


## Best Practices

- Use environment variables for AWS credentials
- Implement proper state management and locking
- Regularly update Terraform and provider versions
- Use consistent naming conventions across resources

## Contributing

Contributions to improve the infrastructure code are welcome. Please follow these steps:

1. Fork the repository
2. Create a new branch for your feature
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## Estructure
````

````

## License

This code is released under the MIT License. See [LICENSE.txt](LICENSE.txt).