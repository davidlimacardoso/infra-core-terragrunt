terraform {
  source = "git@github.com:davidlimacardoso/infra-core-terraform-modules//modules/security-groups"
  // source = "../../../../../infra-core-terraform-modules/modules/security-groups"
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
          security_groups = []
          description = "Allow ingress external connect to Redis"
        },
        {
          from_port   = 6379,
          to_port     = 6379,
          protocol    = "tcp",
          cidr_blocks = ["172.16.0.0/16"]
          security_groups = []
          description = "Allow ingress internal connect to Redis"
        }
      ]
    }

    vprofile-app-sg = {
      description = "Security group app tomcat"
      name        = "vprofile-app-sg"
      ingress = [
        {
          from_port   = 8080,
          to_port     = 8080,
          protocol    = "tcp",
          cidr_blocks = []
          security_groups = ["sg-0930bd37b07c313ad","sg-0e5c76e6a0559b737"],
          description = "Allow ingress from ELB"
        },
        {
          from_port   = 22,
          to_port     = 22,
          protocol    = "tcp",
          cidr_blocks = []
          security_groups = ["sg-0e5c76e6a0559b737"],
          description = "Allow ssh connect from bastion"
        }
      ]
    }

    vprofile-elb-sg = {
      description = "Security group for ELB Vprofile"
      name        = "vprofile-elb-sg"
      ingress = [
        {
          from_port   = 80,
          to_port     = 80,
          protocol    = "tcp",
          cidr_blocks = ["0.0.0.0/0"]
          security_groups = []
          description = "Allow all http ingress to ELB"
        },
        {
          from_port   = 443,
          to_port     = 443,
          protocol    = "tcp",
          cidr_blocks = ["0.0.0.0/0"]
          security_groups = []
          description = "Allow all https ingress to ELB"
        }
      ]
    }

    vprofile-bastion-sg = {
      description = "Security group to bastion access"
      name        = "vprofile-app-sg"
      ingress = [
        {
          from_port   = 22,
          to_port     = 22,
          protocol    = "tcp",
          cidr_blocks = ["0.0.0.0/0"]
          security_groups = [],
          description = "Allow ssh ingress"
        }
      ]
    }
  }

}