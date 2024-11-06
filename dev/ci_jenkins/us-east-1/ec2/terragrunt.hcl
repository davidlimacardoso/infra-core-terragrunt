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

    // Ubuntu Jenkins - Tomcat - JDK
    {
      instance_name   = "jenkins-server"
      instance_type   = "t3.medium"
      ami             = "ami-0866a3c8686eaeeba"
      subnet          = dependency.vpc.outputs.private_subnet_ids[0]
      security_groups = [dependency.sg.outputs.id["jenkins_sg"]]
      user_data       = <<-EOF
                #!/bin/bash
                sudo apt update -y
                # sudo apt upgrade -y
                sudo apt install openjdk-11-jdk -y
                sudo apt install openjdk-17-jdk -y
                sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
                  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
                echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
                  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
                  /etc/apt/sources.list.d/jenkins.list > /dev/null
                sudo apt-get update -y
                sudo apt-get install jenkins -y 
                sudo apt install maven -y
              EOF
    },
    // Nexus
    {
      instance_name   = "nexus-server"
      instance_type   = "t3.medium"
      ami             = "ami-06b21ccaeff8cd686"
      subnet          = dependency.vpc.outputs.private_subnet_ids[0]
      security_groups = [dependency.sg.outputs.id["nexus_sg"]]
      user_data       = <<-EOF
                #!/bin/bash

                sudo rpm --import https://yum.corretto.aws/corretto.key
                sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo

                sudo yum install -y java-17-amazon-corretto-devel wget -y

                mkdir -p /opt/nexus/   
                mkdir -p /tmp/nexus/                           
                cd /tmp/nexus/
                NEXUSURL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"
                wget $NEXUSURL -O nexus.tar.gz
                sleep 10
                EXTOUT=`tar xzvf nexus.tar.gz`
                NEXUSDIR=`echo $EXTOUT | cut -d '/' -f1`
                sleep 5
                rm -rf /tmp/nexus/nexus.tar.gz
                cp -r /tmp/nexus/* /opt/nexus/
                sleep 5
                useradd nexus
                chown -R nexus.nexus /opt/nexus 
                cat <<EOT>> /etc/systemd/system/nexus.service
                [Unit]                                                                          
                Description=nexus service                                                       
                After=network.target                                                            
                                                                                  
                [Service]                                                                       
                Type=forking                                                                    
                LimitNOFILE=65536                                                               
                ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start                                  
                ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop                                    
                User=nexus                                                                      
                Restart=on-abort                                                                
                                                                                  
                [Install]                                                                       
                WantedBy=multi-user.target                                                      

                EOT

                echo 'run_as_user="nexus"' > /opt/nexus/$NEXUSDIR/bin/nexus.rc
                systemctl daemon-reload
                systemctl start nexus
                systemctl enable nexus
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
