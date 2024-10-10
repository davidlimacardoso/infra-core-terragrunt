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
          records = [dependency.ec2.outputs.ec2_private_ip["vprofile-db01"].private_ip]
        },
        {
          name = "mc01.vprofile.in"
          type = "A"
          ttl = 300
          records = [dependency.ec2.outputs.ec2_private_ip["vprofile-mc01"].private_ip]
        },
        {
          name = "rmq.vprofile.in"
          type = "A"
          ttl = 300
          records = [dependency.ec2.outputs.ec2_private_ip["vprofile-rmq01"].private_ip]
        }
      ]
    }
  
  ]
}