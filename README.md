# Terraform AWS Starter

### Welcome to the repo!!

Here you'll find the necessary Terraform code you can use to spin up AWS resources without having to to do much configurations.

Here are the AWS resources that will be provisioned when you run Terraform:
- API Gateway
- Lambda 
- Cloud Watch

Coming Soon:
- RDS PostgresSQL
- AWS Cognito

Note: IAM policies and Roles will be integrated but are not listed as an AWS resources above.

## How to Run Terraform
1. Download Terraform CLI
2. Download Access Key & Secret from your AWS account (IAM -> Security Credentials) and set Key & Secret in env Variables or in provider.tf(not recomended) as such:  

provider "aws" {
  region     = "us-west-1"
  access_key = "YOUR_AWS_ACCESS_KEY"
  secret_key = "YOUR_AWS_SECRET_KEY"
}  

** NOTE: Do NOT commit provider.tf if you're hard coding it in provider.tf**

Coming Soon!
