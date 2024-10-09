terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

inputs = {
  env = "dev"
  default = [
    {
      name        = "jupter.xyz"
      domain_name = "*.jupter.xyz"
    }
  ]
}