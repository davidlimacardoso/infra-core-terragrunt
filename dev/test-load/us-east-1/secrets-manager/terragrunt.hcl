terraform {
    source = "."
#   source = "git@github.com:amedigital-internal/infra-terragrunt-modules//network-core?ref=fix/tgw_var_route"
  # source = "/home/david/git_ame/infra-terragrunt-modules/network-core"
}


include {
  path = find_in_parent_folders()
}


inputs = {

  env = "dev"
  project = "k6"
  name = "test-load"

  secret_value = [
    {
      key  = "OUTPUT"
      value = "--out influxdb=http://grafana.k6testload.in:8086/k6"
    },
    {
      key  = "TOKEN"
      value = "###"
    }
    ,{
      key  = "ANOTHER_TOKEN"
      value = "###"
    }
  ]
}