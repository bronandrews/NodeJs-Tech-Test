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
### This role must trust the Jenkins IAM user and EC2/EKS services
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = data.aws_iam_user.jenkins.arn,
        Service = ["ec2.amazonaws.com", "eks.amazonaws.com"]
      },
      Action = "sts:AssumeRole"
    }]
  })
}

### attach standard EKS policies
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "worker_node_eks" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "worker_node_cni" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "worker_node_ecr" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
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
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.worker_node_eks,
    aws_iam_role_policy_attachment.worker_node_cni,
    aws_iam_role_policy_attachment.worker_node_ecr
  ]
}

#### Create nodes for this cluster, to run the Service on
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "default"
  node_role_arn   = aws_iam_role.eks_cluster_role.arn
  subnet_ids      = data.aws_subnets.public.ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3a.small"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.worker_node_eks,
    aws_iam_role_policy_attachment.worker_node_cni,
    aws_iam_role_policy_attachment.worker_node_ecr
  ]
}



#####  Kubernetes Provider
provider "kubernetes" {
  host                   = aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

#####  aws-auth ConfigMap 
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.eks_cluster_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])

    mapUsers = yamlencode([
      {
        userarn  = data.aws_iam_user.jenkins.arn
        username = "dev-user"
        groups   = ["system:masters"]
      }
    ])
  }
}