terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("network-core")
}

inputs = {
  hosted_zones = [

    {
      name = "vprofile.in"
      private = true
      vpc_id = dependency.vpc.outputs.vpc_id
      records = [
        {
          name = "db01.vprofile.in"
          type = "A"
          ttl = 300
          records = ["10.248.242.73"]
        },
        {
          name = "mc01.vprofile.in"
          type = "A"
          ttl = 300
          records = ["10.248.242.88"]
        },
        {
          name = "rmq.vprofile.in"
          type = "A"
          ttl = 300
          records = ["10.248.241.12"]
        }
      ]
    }
  
  ]
}