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
          description = "Allow ssh connect from bastion"
        }
      ]
    }

    vprofile-backend-sg = {
      description = "Security group for backend instances"
      name        = "vprofile-backend-sg"
      ingress = [
        {
          from_port   = 11211,
          to_port     = 11211,
          protocol    = "tcp",
          cidr_blocks = []
          description = "Allow access from Tomcat server to Memcache"
        },
        {
          from_port   = 3306,
          to_port     = 3306,
          protocol    = "tcp",
          cidr_blocks = []
          description = "Allow access from Tomcat server to MariaDB"
        },
        {
          from_port   = 5672,
          to_port     = 5672,
          protocol    = "tcp",
          cidr_blocks = []
          description = "Allow access from Tomcat server to RabbitMQ"
        },
        {
          from_port   = 22,
          to_port     = 22,
          protocol    = "tcp",
          cidr_blocks = []
          description = "Allow ssh connect from bastion"
        },
        {
          from_port   = 0,
          to_port     = 0,
          protocol    = "-1",
          cidr_blocks = []
          description = "Allow all trafic connect from bastion"
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
      name        = "vprofile-bastion-sg"
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