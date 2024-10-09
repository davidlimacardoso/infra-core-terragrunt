terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

inputs = {
  roles = [
    {
      name = "ec2-instance-s3-connect"
      description = "Role for EC2 instance to connect to S3"
      assume_role_policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "sts:AssumeRole"
              ],
              "Principal" : {
                "Service" : [
                  "ec2.amazonaws.com"
                ]
              }
            }
          ]
        }
      )

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:PutObject",
              "s3:ListBucket"
            ]
            Resource = [
              "arn:aws:s3:::vprofile-project-dev-artifacts",
              "arn:aws:s3:::vprofile-project-dev-artifacts/*"
            ]
          }
        ]
      })
    }
  ]
}