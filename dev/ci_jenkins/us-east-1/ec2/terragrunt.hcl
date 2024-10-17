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

  key_pair_name = "jenkins-key"
  instance_settings = [

    // Ubuntu web Tomcat instance
    {
      instance_name   = "jenkins-server"
      instance_type   = "t2.micro"
      ami             = "ami-005fc0f236362e99f"
      subnet          = dependency.vpc.outputs.private_subnet_ids[0]
      security_groups = [dependency.sg.outputs.id["jenkins_sg"]]
      user_data       = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install openjdk-11-jdk -y
                sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
                  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
                echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
                  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
                  /etc/apt/sources.list.d/jenkins.list > /dev/null
                sudo apt-get update -y
                sudo apt-get install jenkins -y 
              EOF
    },
    // Bastion Instance
    {
      instance_name               = "ci-bastion"
      instance_type               = "t2.micro"
      ami                         = "ami-0ebfd941bbafe70c6"
      subnet                      = dependency.vpc.outputs.public_subnet_ids[0]
      security_groups             = [dependency.sg.outputs.id["bastion_sg"]]
      associate_public_ip_address = true
    }
  ]

}
