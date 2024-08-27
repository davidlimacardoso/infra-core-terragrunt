terraform {
  source = "https://github.com/davidlimacardoso/infra-core-terraform-modules//network-core"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  vpc_cidr_block = "172.16.0.0/16"
  vpc_name       = "crow-tester-vpc"
  igw_name       = "crow-tester-igw-core"
  nat_gateway    = "crow-tester-nat"
  elastic_ip     = "crow-tester-eip"
  single_nat     = true

  private_subnets = [
    {
      name        = "crow-tester-infra-private"
      cidr_blocks = ["172.16.4.0/22", "172.16.8.0/22"]
      tag         = "infra"
    }
  ]

  public_subnets = [
    {
      name        = "crow-tester-infra-public"
      cidr_blocks = ["172.16.0.16/28"]
      tag         = "infra"
    }
  ]

}
