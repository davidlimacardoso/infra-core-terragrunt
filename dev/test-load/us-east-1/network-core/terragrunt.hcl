terraform {
  source = "git@github.com:davidlimacardoso/infra-core-terraform-modules//modules/network-core"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  vpc_cidr_block = "172.120.0.0/16"
  vpc_name       = "k6-dev-tester-vpc"
  igw_name       = "k6-dev-tester-igw-core"
  nat_gateway    = "k6-dev-tester-nat"
  elastic_ip     = "k6-dev-tester-eip"
  single_nat     = true

  private_subnets = [
    {
      name        = "k6-dev-tester-infra-private"
      cidr_blocks = ["172.120.4.0/22", "172.120.8.0/22"]
      tag         = "infra"
    }
  ]

  public_subnets = [
    {
      name        = "k6-dev-tester-infra-public"
      cidr_blocks = ["172.120.0.16/28","172.120.200.0/24"]
      tag         = "infra"
    }
  ]

}
