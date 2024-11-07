
terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("network-core")
}

dependency "ec2" {
  config_path = find_in_parent_folders("ec2")
}

##################################################################################
# Create internal hosted domain name to be used as OUTPUT throught of the K6 by Secrets Manager

inputs ={

  private = {
    name   = "devops.in"
    vpc_id = dependency.vpc.outputs.vpc_id
    records = [
      {
        name    = "sonar.dev"
        type    = "A"
        ttl     = 300
        records = [dependency.ec2.outputs.instances.sonar-server.private_ip]
      },
      {
        name    = "nexus.dev"
        type    = "A"
        ttl     = 300
        records = [dependency.ec2.outputs.instances.nexus-server.private_ip]
      },
      {
        name    = "jenkins.dev"
        type    = "A"
        ttl     = 300
        records = [dependency.ec2.outputs.instances.jenkins-server.private_ip]
      }      
    ]
  }
}
