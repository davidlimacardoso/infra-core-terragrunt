resource "aws_s3_bucket" "codepipeline_artifact" {
  bucket = "${var.project}-${var.env}-${var.bucket_artifact_name}"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.project}-${var.env}-${var.bucket_codepipeline_name}"
}