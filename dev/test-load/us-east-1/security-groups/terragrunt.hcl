terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("network-core")
}

inputs = {

  vpc_id = dependency.vpc.outputs.vpc_id
  env = "dev"
  project = "k6"

  sg_ingress = {

    codebuild-sg = {
      description = "Security to codebuild instances"
      name        = "codebuild-sg"
      ingress = [
        {
          from_port   = 443,
          to_port     = 443,
          protocol    = "tcp",
          cidr_blocks = [dependency.vpc.outputs.vpc_cdir_block]
          description = "Allow internal traffic HTTPS to VPC"
        }
      ]
    }
  }

}