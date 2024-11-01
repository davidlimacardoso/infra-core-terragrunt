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
  env = "dev"
  project = "k6"

  sg_ingress = {

    # SG for codebuild 
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

  # SG for grafana/influxdb instance
  grafana-instance-sg = {
      description = "Security group to Grafana and Influxdb instance"
      name        = "grafana-instance-sg"
      ingress = [
        {
          from_port   = 22,
          to_port     = 22,
          protocol    = "tcp",
          cidr_blocks = []
          description = "Allow ssh connect from bastion"
        },
        {
          from_port   = 8086,
          to_port     = 8086,
          protocol    = "tcp",
          cidr_blocks = [dependency.vpc.outputs.vpc_cdir_block]
          security_groups = []
          description = "Allow ingress to InfluxDB through VPC"
        },
        {
          from_port   = 3000,
          to_port     = 3000,
          protocol    = "tcp",
          cidr_blocks = []
          security_groups = []
          description = "Allow Grafana ingress from Load Balancer"
        }
      ]
    }

    # SG for bastion instance
    bastion-sg = {
      description = "Security group to bastion access"
      name        = "bastion-sg"
      ingress = [
        {
          from_port   = 22,
          to_port     = 22,
          protocol    = "tcp",
          cidr_blocks = ["${local.my_ip}"]
          description = "Allow ssh to private ip to internet"
        }
      ]
    }

    # SG for ELB Grafana instance
    elb-sg = {
      description = "Security group for ELB Grafana instance"
      name        = "grafana-elb-sg"
      ingress = [
        {
          from_port   = 80,
          to_port     = 80,
          protocol    = "tcp",
          cidr_blocks = ["${local.my_ip}"]
          security_groups = []
          description = "Allow restrict http access to the ELB"
        },
        {
          from_port   = 443,
          to_port     = 443,
          protocol    = "tcp",
          cidr_blocks = ["${local.my_ip}"]
          security_groups = []
          description = "Allow restrict https access to the ELB"
        }
      ]
    }
  }
}