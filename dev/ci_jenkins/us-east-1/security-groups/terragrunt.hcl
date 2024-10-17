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

  sg_ingress = {

    jenkins-server = {
      description = "Security group to jenkins"
      name        = "jenkins-server-sg"
      ingress = [
        {
          from_port   = 22,
          to_port     = 22,
          protocol    = "tcp",
          cidr_blocks = []
          description = "Allow ssh connect from bastion"
        },
        {
          from_port   = 8080,
          to_port     = 8080,
          protocol    = "tcp",
          cidr_blocks = []
          security_groups = ["sg-069cf8d0d9dcd6b81"],
          description = "Allow ingress from ELB"
        }
      ]
    }

    bastion-sg = {
      description = "Security group to bastion access"
      name        = "ci-bastion-sg"
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

    jenkins-elb-sg = {
      description = "Security group for ELB Jenkins"
      name        = "jenkins-elb-sg"
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
  }

}