terraform {
  backend "s3" {
    key    = "ECR/Main/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {}


## Create ECR repo for NodeJs images
resource "aws_ecr_repository" "repo" {
  name = lower(var.profile)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "other" {
  repository = aws_ecr_repository.repo.name

  policy = jsonencode(
    {
      Version = "2008-10-17"
      Statement = [
        {
          Sid    = "TaskExecutionReadOnly"
          Effect = "Allow"
          Principal = "*"
          Action = [
            #Following copied from AmazonEC2ContainerRegistryReadOnly
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:DescribeImages",
            "ecr:BatchGetImage",
            "ecr:GetLifecyclePolicy",
            "ecr:GetLifecyclePolicyPreview",
            "ecr:ListTagsForResource",
            "ecr:DescribeImageScanFindings"
          ]
        }
      ]
    }
  )
}
