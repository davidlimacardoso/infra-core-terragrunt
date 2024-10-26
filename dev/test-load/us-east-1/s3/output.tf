output "bucket" {
  value = {
    artifact_store = aws_s3_bucket.codepipeline_artifact.id
    codepipeline   = aws_s3_bucket.codepipeline_bucket.id
  }
  description = "Bucket information"
}