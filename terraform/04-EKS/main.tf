terraform {
  backend "s3" {
    key    = "EKS/Main/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region  = "eu-west-1"
}

#### Retrieve Subnet Ids for our VPC
data "aws_vpc" "main" {
  tags = {
    Name = "${var.profile}-VPC"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

### Retrieve jenkins user - which will assume the EKS role, for access
data "aws_iam_user" "jenkins" {
  user_name = "jenkins-ecr-user"
}

### Create role with access to EKS
### This role must trust the Jenkins IAM user
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = data.aws_iam_user.jenkins.arn
      },
      Action = "sts:AssumeRole"
    }]
  })
}

### attach standard EKS policy
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


##### Create an EKS Cluster
##### Using public subnets for this test
resource "aws_eks_cluster" "eks" {
  name     = "nodejs-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.29"

  vpc_config {
    subnet_ids = data.aws_subnets.public.ids
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}
