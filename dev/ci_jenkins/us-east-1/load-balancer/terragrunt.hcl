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

dependency "ec2" {
  config_path = find_in_parent_folders("ec2")
}

dependency "acm" {
  config_path = find_in_parent_folders("acm")
}

inputs = {
  env = "dev"
  alb = [
    
    {
     name = "jenkins-server"
      health_path = "/login"
      port = 8080
      vpc_id = dependency.vpc.outputs.vpc_id
      instance_id = dependency.ec2.outputs.ec2_instance["jenkins-server"]
      lb_security_group =  [dependency.sg.outputs.id["elb_sg"]]
      subnets = dependency.vpc.outputs.public_subnet_ids
      certificate_arn = dependency.acm.outputs.certificate["*.jupter.xyz"]
    },
    {
     name = "nexus-server"
      health_path = "/"
      port = 8081
      vpc_id = dependency.vpc.outputs.vpc_id
      instance_id = dependency.ec2.outputs.ec2_instance["nexus-server"]
      lb_security_group =  [dependency.sg.outputs.id["nexus_elb_sg"]]
      subnets = dependency.vpc.outputs.public_subnet_ids
      certificate_arn = dependency.acm.outputs.certificate["*.jupter.xyz"]
    },
    {
     name = "sonar-server"
      health_path = "/"
      port = 80
      vpc_id = dependency.vpc.outputs.vpc_id
      instance_id = dependency.ec2.outputs.ec2_instance["sonar-server"]
      lb_security_group =  [dependency.sg.outputs.id["sonar_elb_sg"]]
      subnets = dependency.vpc.outputs.public_subnet_ids
      certificate_arn = dependency.acm.outputs.certificate["*.jupter.xyz"]
    }
  ]
}