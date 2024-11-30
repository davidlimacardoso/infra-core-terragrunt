terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("network-core")
}

dependency "sg" {
  config_path = find_in_parent_folders("security-groups")
}

inputs = {

  key_pair_name = "control-key"
  instance_settings = [

    // Ubuntu with Ansible Controller
    {
      instance_name   = "control-server"
      instance_type   = "t3.medium"
      ami             = "ami-0866a3c8686eaeeba"
      subnet          = dependency.vpc.outputs.public_subnet_ids[0]
      security_groups = [dependency.sg.outputs.id["control_sg"]]
      user_data       = <<-EOF
                #!/bin/bash
                apt update
                apt install software-properties-common -y
                add-apt-repository --yes --update ppa:ansible/ansible
                apt install ansible -y
              EOF
      associate_public_ip_address = true
    },
    // Webservers
    {
      instance_numbers  = 3
      instance_name     = "vprofile-web"
      instance_type     = "t3.medium"
      ami               = "ami-0df2a11dd1fe1f8e3" // CentOS
      subnet            = dependency.vpc.outputs.public_subnet_ids[0]
      security_groups   = [dependency.sg.outputs.id["control_sg"]]
      associate_public_ip_address = true
    },
    // Ubuntu with Ansible Controller
    {
      instance_name   = "vprofile-web-4"
      instance_type   = "t3.medium"
      ami             = "ami-0866a3c8686eaeeba"
      subnet          = dependency.vpc.outputs.public_subnet_ids[0]
      security_groups = [dependency.sg.outputs.id["control_sg"]]
      associate_public_ip_address = true
    }
  ]

}
