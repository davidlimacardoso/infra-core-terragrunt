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

    control-server = {
      description = "Security group to control server Ansible"
      name        = "control-server-sg"
      ingress = [
        {
          from_port   = 22,
          to_port     = 22,
          protocol    = "tcp",
          cidr_blocks = []
          description = "Allow ssh connect from bastion"
        }
      ]
    }

    bastion-sg = {
      description = "Security group to bastion access"
      name        = "control-bastion-sg"
      ingress = [
        {
          from_port   = 22,
          to_port     = 22,
          protocol    = "tcp",
          cidr_blocks = ["${local.my_ip}"]
          security_groups = [],
          description = "Allow ssh ingress to private IP"
        }
      ]
    }

  }

}