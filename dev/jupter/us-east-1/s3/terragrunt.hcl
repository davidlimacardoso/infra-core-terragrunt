terraform {
  source = "git@github.com:davidlimacardoso/infra-core-terraform-modules//modules/s3"
}

include {
  path = find_in_parent_folders()
}

inputs = {
    buckets = [
        {
            name = "vprofile-dev-artifacts",
            acl = "private",
            versioning = true,
            force_destroy = false,
            object_lock_enabled = false
        }
    ]
}