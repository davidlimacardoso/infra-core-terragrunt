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

  key_pair_name = "k6-test-load-key"
  instance_settings = [

    // Grafana instance to Load Test with k6
    {
      instance_name   = "grafana-k6-test-load"
      instance_type   = "t2.micro"
      ami             = "ami-0866a3c8686eaeeba"
      subnet          = dependency.vpc.outputs.private_subnet_ids[0]
      security_groups = [dependency.sg.outputs.id["grafana_sg"]]
      user_data       = <<-EOF
                #!/bin/bash
                sudo apt update
                sudo apt upgrade -y 
                sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

                #Setting Docker and Docker Compose
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
                sudo apt update
                sudo apt install docker-ce docker-compose -y

                # Clone repository
                cd /home/ubuntu
                git clone https://github.com/davidlimacardoso/k6-multi-load-tests.git
                cd k6-multi-load-tests/docker/grafana

                # Execute containers
                sudo docker compose up -d

                #Set containers to start automatically
                sudo docker update --restart always grafana-influxdb-1
                sudo docker update --restart always grafana-grafana-1
                
                # Configure Influxdb conection and dashboard to grafana
                sleep 30
                sudo chmod +x dashboard.sh 
                sudo ./dashboard.sh
              EOF
    },
    // Bastion Instance
    {
      is_bastion = true
      instance_name               = "grafana-bastion"
      instance_type               = "t2.micro"
      ami                         = "ami-0ebfd941bbafe70c6"
      subnet                      = dependency.vpc.outputs.public_subnet_ids[0]
      security_groups             = [dependency.sg.outputs.id["bastion_sg"]]
      associate_public_ip_address = true
    }
  ]

}
