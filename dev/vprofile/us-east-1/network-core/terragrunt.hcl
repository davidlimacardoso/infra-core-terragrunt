terraform {
  # source = "git@github.com:davidlimacardoso/infra-core-terraform-modules//modules/network-core"
  source = "../../../../../infra-core-terraform-modules/modules/network-core"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  vpc_cidr_block = "10.180.0.0/16"
  vpc_name       = "vprofile-dev-vpc"
  igw_name       = "vprofile-dev-igw-core"
  nat_gateway    = "vprofile-dev-nat"
  elastic_ip     = "vprofile-dev-eip"
  single_nat     = false

  private_subnets = [
    {
      name        = "vprofile-dev-infra-private"
      cidr_blocks = ["10.180.224.0/21", "10.180.232.0/21","10.180.240.0/21","10.180.248.0/21","10.180.176.0/21"]
      tag         = "infra"
    }
  ]

  public_subnets = [
    {
      name        = "vprofile-dev-infra-public"
      cidr_blocks = ["10.180.160.0/21","10.180.168.0/21"]
      tag         = "infra"
    }
  ]

}
