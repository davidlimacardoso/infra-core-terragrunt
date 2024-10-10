terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

# dependency "ec2" {
#   config_path = find_in_parent_folders("ec2")
# }

# dependency "sg" {
#   config_path = find_in_parent_folders("security-groups")
# }

# dependency "vpc" {
#   config_path = find_in_parent_folders("network-core")
# }

# dependency "elb" {
#   config_path = find_in_parent_folders("load-balancer")
# }

inputs = {

  name   = "vprofile-app01"
  ec2_instance_id = "i-051d1de710dc829cd" # dependency.ec2.outputs.ec2_instance["vprofile-app01"]
  instance_type = "t2.micro"
  key_pair_name = "vprofile-dev-pair"
  security_group = ["sg-0e8edd96359b7d506"]
  ec2_instance_profile = "ec2-instance-profile-vprofile-app01" # dependency.ec2.outputs.iam_instance_profile["ec2-instance-profile-vprofile-app01"]
  vpc_zone_identifier = ["subnet-0c9478d9da82f0579",  "subnet-04e972ab97a50a310"]  # dependency.vpc.outputs.public_subnet_ids
  target_group_arns = ["arn:aws:elasticloadbalancing:us-east-1:893777461466:targetgroup/vprofile-app-lb-tg/30519e759265ffd4"] # dependency.elb.outputs.target_group["vprofile-app-lb-tg"]
}
