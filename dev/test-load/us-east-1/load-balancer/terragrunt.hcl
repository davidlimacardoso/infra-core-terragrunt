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

# dependency "acm" {
#   config_path = find_in_parent_folders("acm")
# }

inputs = {
  env = "dev"
  project = "k6"
  alb = [
    
    {
     name = "grafana"
      health_path = "/api/health"
      vpc_id = dependency.vpc.outputs.vpc_id
      instance_id = dependency.ec2.outputs.ec2_instance["grafana-k6-test-load"]
      lb_security_group =  [dependency.sg.outputs.id["elb_sg"]]
      subnets = dependency.vpc.outputs.public_subnet_ids
    }
  ]
}