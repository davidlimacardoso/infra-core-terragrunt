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
    // Ubuntu Sonar
    {
      instance_name   = "sonar-server"
      instance_type   = "t3.medium"
      ami             = "ami-0866a3c8686eaeeba"
      subnet          = dependency.vpc.outputs.private_subnet_ids[0]
      security_groups = [dependency.sg.outputs.id["sonar_sg"]]
      user_data       = <<-EOF
                #!/bin/bash
                cp /etc/sysctl.conf /root/sysctl.conf_backup
                cat <<EOT> /etc/sysctl.conf
                vm.max_map_count=262144
                fs.file-max=65536
                ulimit -n 65536
                ulimit -u 4096
                EOT
                cp /etc/security/limits.conf /root/sec_limit.conf_backup
                cat <<EOT> /etc/security/limits.conf
                sonarqube   -   nofile   65536
                sonarqube   -   nproc    409
                EOT

                sudo apt-get update -y
                sudo apt-get install openjdk-17-jdk -y
                sudo update-alternatives --config java

                java -version

                sudo apt update
                wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -

                sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
                sudo apt install postgresql postgresql-contrib -y
                #sudo -u postgres psql -c "SELECT version();"
                sudo systemctl enable postgresql.service
                sudo systemctl start  postgresql.service
                sudo echo "postgres:admin123" | chpasswd
                runuser -l postgres -c "createuser sonar"
                sudo -i -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'admin123';"
                sudo -i -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
                sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;"
                systemctl restart  postgresql
                #systemctl status -l   postgresql
                netstat -tulpena | grep postgres
                sudo mkdir -p /sonarqube/
                cd /sonarqube/
                #sudo curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.3.0.34182.zip
                sudo curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.7.96285.zip
                sudo apt-get install zip -y
                sudo unzip -o sonarqube-9.9.7.96285.zip -d /opt/
                sudo mv /opt/sonarqube-9.9.7.96285/ /opt/sonarqube
                sudo groupadd sonar
                sudo useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar
                sudo chown sonar:sonar /opt/sonarqube/ -R
                cp /opt/sonarqube/conf/sonar.properties /root/sonar.properties_backup
                cat <<EOT> /opt/sonarqube/conf/sonar.properties
                sonar.jdbc.username=sonar
                sonar.jdbc.password=admin123
                sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
                sonar.web.host=0.0.0.0
                sonar.web.port=9000
                sonar.web.javaAdditionalOpts=-server
                sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
                sonar.log.level=INFO
                sonar.path.logs=logs
                EOT

                cat <<EOT> /etc/systemd/system/sonarqube.service
                [Unit]
                Description=SonarQube service
                After=syslog.target network.target

                [Service]
                Type=forking

                ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
                ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

                User=sonar
                Group=sonar
                Restart=always

                LimitNOFILE=65536
                LimitNPROC=4096


                [Install]
                WantedBy=multi-user.target
                EOT

                systemctl daemon-reload
                systemctl enable sonarqube.service
                #systemctl start sonarqube.service
                #systemctl status -l sonarqube.service
                apt-get install nginx -y
                rm -rf /etc/nginx/sites-enabled/default
                rm -rf /etc/nginx/sites-available/default
                cat <<EOT> /etc/nginx/sites-available/sonarqube
                server{
                    listen      80;
                    server_name sonarqube.groophy.in;

                    access_log  /var/log/nginx/sonar.access.log;
                    error_log   /var/log/nginx/sonar.error.log;

                    proxy_buffers 16 64k;
                    proxy_buffer_size 128k;

                    location / {
                        proxy_pass  http://127.0.0.1:9000;
                        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
                        proxy_redirect off;

                        proxy_set_header    Host            \$host;
                        proxy_set_header    X-Real-IP       \$remote_addr;
                        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
                        proxy_set_header    X-Forwarded-Proto http;
                    }
                }
                EOT
                ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/sonarqube
                systemctl enable nginx.service
                #systemctl restart nginx.service
                sudo ufw allow 80,9000,9001/tcp

                echo "System reboot in 30 sec"
                sleep 30
                reboot
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
