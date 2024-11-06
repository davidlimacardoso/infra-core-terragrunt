terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("network-core")
}

locals {
  # See my private ip to use to restrict access from security group
  my_ip = "${run_cmd("sh", "-c", "curl -s https://checkip.amazonaws.com")}/32"
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
          cidr_blocks = ["${local.my_ip}"]
          description = "Allow ssh connect from bastion"
        },
        {
          from_port   = 8080,
          to_port     = 8080,
          protocol    = "tcp",
          cidr_blocks = []
          security_groups = [],
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
          cidr_blocks = ["${local.my_ip}"]
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
          cidr_blocks = ["${local.my_ip}"]
          security_groups = []
          description = "Allow all http ingress to ELB"
        },
        {
          from_port   = 443,
          to_port     = 443,
          protocol    = "tcp",
          cidr_blocks = ["${local.my_ip}"]
          security_groups = []
          description = "Allow all https ingress to ELB"
        }
      ]
    }

    nexus-sg = {
      description = "Security group to nexus"
      name        = "nexus-sg"
      ingress = [
        {
          from_port   = 8081,
          to_port     = 8081,
          protocol    = "tcp",
          cidr_blocks = []
          security_groups = [],
          description = "Allow ingress from ELB"
        },
        {
          from_port   = 22,
          to_port     = 22,
          protocol    = "tcp",
          cidr_blocks = []
          security_groups = [],
          description = "Allow ssh ingress"
        }
      ]
    }

    nexus-elb-sg = {
      description = "Security group to nexus"
      name        = "nexus-elb-sg"
      ingress = [
        {
          from_port   = 80,
          to_port     = 80,
          protocol    = "tcp",
          cidr_blocks = ["${local.my_ip}"]
          security_groups = []
          description = "Allow all http ingress to ELB"
        },
        {
          from_port   = 443,
          to_port     = 443,
          protocol    = "tcp",
          cidr_blocks = ["${local.my_ip}"]
          security_groups = []
          description = "Allow all https ingress to ELB"
        }
      ]
    }

    sonar-sg = {
      description = "Security group to Sonar"
      name        = "sonar-sg"
      ingress = [
        {
          from_port   = 80,
          to_port     = 80,
          protocol    = "tcp",
          cidr_blocks = ["${local.my_ip}"]
          security_groups = [],
          description = "Allow ingress from ELB"
        },
        {
          from_port   = 22,
          to_port     = 22,
          protocol    = "tcp",
          cidr_blocks = []
          security_groups = [],
          description = "Allow ssh ingress"
        }
      ]
    }

    sonar-elb-sg = {
      description = "Security group to Sonar"
      name        = "sonar-elb-sg"
      ingress = [
        {
          from_port   = 80,
          to_port     = 80,
          protocol    = "tcp",
          cidr_blocks = ["${local.my_ip}"]
          security_groups = []
          description = "Allow all http ingress to ELB"
        },
        {
          from_port   = 443,
          to_port     = 443,
          protocol    = "tcp",
          cidr_blocks = ["${local.my_ip}"]
          security_groups = []
          description = "Allow all https ingress to ELB"
        }
      ]
    }
  }

}