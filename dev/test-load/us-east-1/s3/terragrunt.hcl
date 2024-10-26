terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

inputs = {

  bucket_artifact_name = "codepipeline-artifact-store"
  bucket_codepipeline_name = "codepipeline"
  env         = "dev"
  project     = "k6"

}