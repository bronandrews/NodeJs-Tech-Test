## DevOps Tech Test 
NodeJs app, run in EKS on AWS

## This project includes:
- NodeJs dockerfile
- Kubernetes deployment files, to deploy NodeJs image
- AWS stack setup written in Terraform, creating resources VPC, IAM, ECR, EKS
- Jenkins pipeline that validates k8s, builds NodeJs docker image, pushes it to ECR and deploys to EKS

## To run the Terraform
### In AWS account - need to manually create the S3 bucket to hold the tfstate

### In each .\terraform sub-folder
```bash
terraform init -backend-config="..\NodeJs.tfbackend
terraform plan
terraform apply
```

## Manual steps
### This assumes access to a live Jenkins server  
### Note - Can use contents of .\script\LocalSetup.txt to create a local Jenkins running in docker

- Need to create the job in Jenkins, linking to Jenkinsfile in this git repo
- Manually create Access Key for jenkins-ecr-user - and link to User/Password credentials in Jenkins
- Configure Email SMTP server in Jenkins
- Configure Web hook to a Slack account

## Changes/Fixes:
- Dockerfile typo - FROM node:18-alpnie
- Dockerfile port fix - EXPOSE 8000 (instead of 3000)

