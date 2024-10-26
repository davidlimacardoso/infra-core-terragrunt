## Data codebuild service assume role
data "aws_iam_policy_document" "codebuild_service_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

## Data Codepipeline service assume role

data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}


##################################################################
## Role to Codebuild
##################################################################

## Codebuild service role
resource "aws_iam_role" "codebuild_service_role" {

  name               = "${local.project_name}-service-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_service_assume_role.json
  path               = "/"
  description        = "CodeBuild service role for ${local.project_name}"
}

## Codebuild service role policy attachment to get secrets in Secrets Manager
resource "aws_iam_role_policy" "inline_policy_codebuild_secrets" {
  name = "${local.project_name}-secrets-role-policy"
  role = aws_iam_role.codebuild_service_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "GetSecret",
        "Effect" : "Allow",
        "Action" : "secretsmanager:GetSecretValue",
        "Resource" : "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:secret/k6-dev-test-load*"
      }
    ]
  })
}

## Codebuild service role policy attachment to allow access for EC2
resource "aws_iam_role_policy" "inline_policy_codebuild_ec2" {
  name = "${local.project_name}-ec2-role-policy"
  role = aws_iam_role.codebuild_service_role.id
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DescribeVpcs",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "AllowEC2Network"
      },
      {
        "Action" : [
          "ec2:CreateNetworkInterfacePermission"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:AuthorizedService" : "codebuild.amazonaws.com"
          }
        },
        "Effect" : "Allow",
        "Resource" : "arn:aws:ec2:${local.region}:${local.account_id}:network-interface/*"
      }
    ],
    "Version" : "2012-10-17"
  })
}

## Codebuild service role policy attachment to allow access for EC2
resource "aws_iam_role_policy" "inline_policy_codebuild_logs" {
  name = "${local.project_name}-cw-role-policy"
  role = aws_iam_role.codebuild_service_role.id
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogStream",
          "logs:GetLogRecord",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "VisualEditor0"
      }
    ],
    "Version" : "2012-10-17"
  })
}

## Codebuild service role policy attachment to allow access for EC2
resource "aws_iam_role_policy" "inline_policy_codebuild_s3" {
  name = "${local.project_name}-s3-role-policy"
  role = aws_iam_role.codebuild_service_role.id
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "s3:GetObject"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${var.s3_artifact_bucket}",
          "arn:aws:s3:::${var.s3_artifact_bucket}/*"
        ]
        "Sid" : "GetArtifact"
      }
    ],
    "Version" : "2012-10-17"
  })
}

# ## Codebuild service role policy attachment to manager ECR and GIT images and commands
resource "aws_iam_role_policy" "inline_policy_codebuild_ecr" {
  name = "${local.project_name}-ecr-role-policy"
  role = aws_iam_role.codebuild_service_role.id
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "ssm:GetParameters",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:UploadLayerPart",
          "ecr:ListImages",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetRepositoryPolicy",
          "ecr:GetAuthorizationToken",
          "ecr:PutImage",
          "codestar-connections:UseConnection",
          "codecommit:GitPull"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "VisualEditor0"
      }
    ],
    "Version" : "2012-10-17"
  })
}

##################################################################
## Codebuild batch executations
##################################################################
resource "aws_iam_role" "codebuild_batch_role" {

  name               = "${local.project_name}-batch-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_service_assume_role.json
  path               = "/service-role/"
  description        = "CodeBuild batch role for ${local.project_name}"

}

resource "aws_iam_role_policy" "inline_policy_codebuild_batch_role" {
  name = "${local.project_name}-batch-build-policy"
  role = aws_iam_role.codebuild_batch_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:codebuild:${local.region}:${local.account_id}:project/${local.project_name}"
        ],
        "Action" : [
          "codebuild:StartBuild",
          "codebuild:StopBuild",
          "codebuild:RetryBuild"
        ]
      }
    ]
  })
}

# resource "aws_iam_role_policy_attachment" "attachment_codebuild_batch_role" {
#   role       = aws_iam_role.codebuild_batch_role.name
#   policy_arn = aws_iam_policy.inline_policy_codebuild_batch_role.arn
# }

##################################################################
## Data Codepipeline role to Git
##################################################################

resource "aws_iam_role" "codepipeline_git" {

  name               = "${local.project_name}-codepipeline-service-git"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
  path               = "/"

}

resource "aws_iam_role_policy" "inline_role_codepipeline_git_policy" {
  name = "${local.project_name}-codepipeline-github-policy"
  role = aws_iam_role.codepipeline_git.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${var.s3_artifact_bucket}",
          "arn:aws:s3:::${var.s3_artifact_bucket}/*"
        ]
      },
      {
        "Action" : [
          "codebuild:BatchGetBuildBatches",
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:StartBuildBatch"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "codestar-connections:*"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:codeconnections:${local.region}:${local.account_id}:connection/${var.git_connection}"
      }
    ]
  })
}