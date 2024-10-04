terraform {
  source = "git@github.com:davidlimacardoso/infra-core-terraform-modules//modules/route53"
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
          records = ["172.16.11.52"]
        },
        {
          name = "mc01.vprofile.in"
          type = "A"
          ttl = 300
          records = ["172.16.8.190"]
        },
        {
          name = "rmq.vprofile.in"
          type = "A"
          ttl = 300
          records = ["172.16.6.192"]
        }
      ]
    }
  
  ]
}