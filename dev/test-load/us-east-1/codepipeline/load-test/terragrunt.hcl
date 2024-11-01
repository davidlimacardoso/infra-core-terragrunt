terraform {
    source = "."
#   source = "git@github.com:amedigital-internal/infra-terragrunt-modules//network-core?ref=fix/tgw_var_route"
  # source = "/home/david/git_ame/infra-terragrunt-modules/network-core"
}


include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("network-core")
}

dependency "s3" {
  config_path = find_in_parent_folders("s3")
}

dependency "sgs" {
  config_path = find_in_parent_folders("security-groups")
}

dependency "asm" {
  config_path = find_in_parent_folders("secrets-manager")
}

inputs = {

  env                     = "dev"
  project                 = "k6"
  name                    = "test-load"
  description             = "Test load for k6"
  vpc_id                  = dependency.vpc.outputs.vpc_id
  private_subnets         = dependency.vpc.outputs.private_subnet_ids
  sg_ids                  = [dependency.sgs.outputs.id["codebuild_sg"]]
  s3_artifact_bucket      = dependency.s3.outputs.bucket["artifact_store"]
  s3_codepipeline_bucket  = dependency.s3.outputs.bucket["codepipeline"]
  asm_keys                = dependency.asm.outputs.secret 
  git_repository          = "davidlimacardoso/k6-multi-load-tests"
  git_branch              = "main"
  container_image         = "davidlimacd/k6-node-alpine:1.0"
  git_connection          = "67cd96b0-5760-482c-913a-47a852460bc1"
  buildspec               = "aws/dev-buildspec.yml"

}