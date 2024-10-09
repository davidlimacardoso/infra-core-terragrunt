terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

inputs = {
    buckets = [
        {
            name = "vprofile-project-dev-artifacts",
            acl = "private",
            versioning = true,
            force_destroy = false,
            object_lock_enabled = false
        }
    ]
}