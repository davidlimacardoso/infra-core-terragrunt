terraform {
  source = "git@github.com:davidlimacardoso/infra-core-terraform-modules//modules/security-group"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("network-core")
}

inputs = {

  vpc_id = dependency.vpc.outputs.vpc_id

  sg_ingress = {
    redis-sg = {
      description = "Security group for Redis"
      name        = "sg-redis"
      ingress = [
        {
          from_port   = 6379,
          to_port     = 6379,
          protocol    = "tcp",
          cidr_blocks = ["152.254.203.2/32"]
          description = "Allow ingress external connect to Redis"
        },
        {
          from_port   = 6379,
          to_port     = 6379,
          protocol    = "tcp",
          cidr_blocks = ["172.16.0.0/16"]
          description = "Allow ingress internal connect to Redis"
        }
      ]
    }
  }

}