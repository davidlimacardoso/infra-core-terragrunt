terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

dependency "ec2" {
  config_path = find_in_parent_folders("ec2")
}

dependency "sg" {
  config_path = find_in_parent_folders("security-groups")
}

dependency "vpc" {
  config_path = find_in_parent_folders("network-core")
}

dependency "elb" {
  config_path = find_in_parent_folders("load-balancer")
}

inputs = {
  name                 = "vprofile-app01"
  ec2_instance_id      = dependency.ec2.outputs.ec2_instance["vprofile-app01"]
  instance_type        = "t2.micro"
  key_pair_name        = dependency.ec2.outputs.key_pair_name
  security_group       = [dependency.sg.outputs.id["vprofile-app-sg"]]
  ec2_instance_profile = dependency.ec2.outputs.iam_instance_profile["ec2-instance-profile-vprofile-app01"]
  vpc_zone_identifier  = dependency.vpc.outputs.private_subnet_ids
  target_group_arns    = [dependency.elb.outputs.target_group["vprofile-app-lb-tg"]]
}
