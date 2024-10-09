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

  key_pair_name = "vprofile-dev-pair"
  instance_settings = [

    // Ubuntu web Tomcat instance
    {
      instance_name   = "vprofile-app01"
      instance_type   = "t2.micro"
      ami             = "ami-005fc0f236362e99f"
      subnet          = dependency.vpc.outputs.private_subnet_ids[0]
      security_groups = [dependency.sg.outputs.id["vprofile-app-sg"]]
      iam_role        = "Ec2InstanceS3ConnectRole"
      user_data       = <<-EOF
                #!/bin/bash
                sudo apt update
                sudo apt upgrade -y
                sudo apt install openjdk-11-jdk -y
                sudo apt install tomcat9 tomcat9-admin tomcat9-docs tomcat9-common git -y
                sudo apt install awscli -y
              EOF
    },
    // MariaDB instance
    {
      instance_name   = "vprofile-db01"
      instance_type   = "t2.micro"
      ami             = "ami-0ebfd941bbafe70c6"
      subnet          = dependency.vpc.outputs.private_subnet_ids[1]
      security_groups = [dependency.sg.outputs.id["vprofile-backend-sg"]]
      user_data       = <<-EOF
                  #!/bin/bash
                  DATABASE_PASS='admin123'
                  sudo yum update -y
                  #sudo yum install epel-release -y
                  sudo yum install git zip unzip -y
                  sudo dnf install mariadb105-server -y
                  # starting & enabling mariadb-server
                  sudo systemctl start mariadb
                  sudo systemctl enable mariadb
                  cd /tmp/
                  git clone -b main https://github.com/hkhcoder/vprofile-project.git
                  #restore the dump file for the application
                  sudo mysqladmin -u root password "$DATABASE_PASS"
                  sudo mysql -u root -p"$DATABASE_PASS" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DATABASE_PASS'"
                  sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
                  sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
                  sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
                  sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
                  sudo mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
                  sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
                  sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'"
                  sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
                  sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
              EOF
    },
    // Memcache instance
    {
      instance_name   = "vprofile-mc01"
      instance_type   = "t2.micro"
      ami             = "ami-0ebfd941bbafe70c6"
      subnet          = dependency.vpc.outputs.private_subnet_ids[1]
      security_groups = [dependency.sg.outputs.id["vprofile-backend-sg"]]
      user_data       = <<-EOF
                  #!/bin/bash
                  sudo dnf install memcached -y
                  sudo systemctl start memcached
                  sudo systemctl enable memcached
                  sudo systemctl status memcached
                  sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
                  sudo systemctl restart memcached
                  sudo yum install firewalld -y
                  sudo systemctl start firewalld
                  sudo systemctl enable firewalld
                  firewall-cmd --add-port=11211/tcp
                  firewall-cmd --runtime-to-permanent
                  firewall-cmd --add-port=11111/udp
                  firewall-cmd --runtime-to-permanent
                  sudo memcached -p 11211 -U 11111 -u memcached -d
              EOF
    },
    // RabbitMQ instance
    {
      instance_name   = "vprofile-rmq01"
      instance_type   = "t2.micro"
      ami             = "ami-0ebfd941bbafe70c6"
      subnet          = dependency.vpc.outputs.private_subnet_ids[0]
      security_groups = [dependency.sg.outputs.id["vprofile-backend-sg"]]
      user_data       = <<-EOF
                #!/bin/bash
                ## primary RabbitMQ signing key
                rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc'
                ## modern Erlang repository
                rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key'
                ## RabbitMQ server repository
                rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key'
                curl -o /etc/yum.repos.d/rabbitmq.repo https://raw.githubusercontent.com/hkhcoder/vprofile-project/aws-LiftAndShift/al2023rmq.repo
                dnf update -y
                ## install these dependencies from standard OS repositories
                dnf install socat logrotate -y
                ## install RabbitMQ and zero dependency Erlang
                dnf install -y erlang rabbitmq-server
                systemctl enable rabbitmq-server
                systemctl start rabbitmq-server
                sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
                sudo rabbitmqctl add_user test test
                sudo rabbitmqctl set_user_tags test administrator
                sudo systemctl restart rabbitmq-server
              EOF
    },
    // Bastion Instance
    {
      instance_name               = "vprofile-bastion"
      instance_type               = "t2.micro"
      ami                         = "ami-0ebfd941bbafe70c6"
      subnet                      = dependency.vpc.outputs.public_subnet_ids[0]
      security_groups             = [dependency.sg.outputs.id["vprofile-bastion-sg"]]
      associate_public_ip_address = true
    }
  ]

}
