terraform {
  backend "s3" {
    key    = "IAM/Main/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region  = "eu-west-1"
}


########################################################################
### User for Jenkins to push to ECR repo
### NOTE - Create Access/Key manually and add to Jenkins credential 
########################################################################
resource "aws_iam_user" "jenkins_ecr" {
  name = "jenkins-ecr-user"
}

resource "aws_iam_user_policy" "jenkins_ecr_policy" {
  name = "JenkinsECRPushPolicy"
  user = aws_iam_user.jenkins_ecr.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      },
      ############################################################
      ## add this section in once EKS cluster is built and role exists
      ############################################################
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
				Resource = "arn:aws:iam::184083913321:role/eks-cluster-role"      
      }
    ]

  })
}

### attach standard AmazonEKSClusterPolicy policy
resource "aws_iam_user_policy_attachment" "eks_access" {
  user       = aws_iam_user.jenkins_ecr.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
