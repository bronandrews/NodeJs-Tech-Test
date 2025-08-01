## DevOps Tech Test 
NodeJs app, run in EKS on AWS

## This project includes:
- NodeJs docker image
- Kubernetes deployment files, to deploy NodeJs image
- AWS stack setup written in Terraform, creating resources VPC, IAM, ECR, EKS
- Jenkins pipeline to that validates k8s, builds NodeJs container image, pushes to ECR and deploys to EKS

## To run the Terraform
### In AWS account - need to manually create bucket

### In each .\terraform sub-folder
```bash
terraform init -backend-config="..\NodeJs.tfbackend
terraform plan
terraform apply
```

### Manual steps
- Create job in Jenkins server linking to Jenkinsfile in this git repo
- Manually create Access Key for jenkins-ecr-user
- Create User/Password credentials in Jenkins for this user
- Configure Email SMTP server in Jenkins
- Web hook to a Slack account

## Changes/Fixes:
- Dockerfile typo - FROM node:18-alpnie
- Dockerfile port fix - EXPOSE 8000 (instead of 3000)

