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
     name = "vprofile-app"
      protocol    = "HTTP"
      port = 8080
      health_port = 8080
      health_path = "/login"
      health_threashold = 2
      vpc_id = dependency.vpc.outputs.vpc_id
      instance_id = dependency.ec2.outputs.ec2_instance["vprofile-app01"]
      lb_security_group =  [dependency.sg.outputs.id["vprofile-elb-sg"]]
      subnets = dependency.vpc.outputs.public_subnet_ids
      certificate_arn = dependency.acm.outputs.certificate["*.jupter.xyz"]
    }
  ]
}