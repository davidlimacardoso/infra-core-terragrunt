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


inputs = {

  private = {
    name = "k6testload.in"
    vpc_id = dependency.vpc.outputs.vpc_id
    records = [
      {
        name = "grafana"
        type = "A"
        ttl = 300
        records = [dependency.ec2.outputs.ec2_private_ip["grafana-k6-test-load"].private_ip]
      }
    ]
  }
}