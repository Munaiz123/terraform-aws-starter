# Terraform AWS Starter

### Welcome to the repo! Don't forget to fork and clone on your local machine!

Here you'll find the necessary Terraform code to spin up AWS resources without having to waste time with configurations. (Details below)

Here are the AWS resources that will be provisioned when you run Terraform (IAM policies/roles will be integrated but are not listed):

- VPC ✅
- EC2 ✅
- RDS PostgresSQL instance ✅
- API Gateway ✅
- Lambda (with S3) ✅
- Cloud Watch (lambda logs) ✅

Coming Soon:
- AWS Cognito
- Lambda connection with provisioned RDS 
- CI/CD
- DRY Terraform Modules 

## Prerequisites
- AWS Access keys need to be configured so that you can provision AWS resources in your account. See the section "Configure Terraform for your AWS account" below for details.

- `/ssh-keys` folder needs to be present in the root directory. This folder will hold AWS public key + secret that allows a user to SSH into the provisions EC2 instance. 
    - Public key + secret need to be downloaded from AWS Account
    - Run this command `ssh-keygen -t rsa -b 2048 -f my_key_pair` while in the /ssh-keys folder. This command generates two files: my_key_pair (private key) and my_key_pair.pub (public key).



## Configure Terraform for your AWS account & Running Terraform
To use Terraform with your AWS account, you need to set up authentication and configure Terraform to communicate with the AWS APIs. Here's a simplified step-by-step guide:

1. **Install Terraform:** Ensure that you have the latest version of Terraform installed on your local machine. You can download it from Terraform's website.

2. **AWS Access Keys:** You need to have an AWS access key ID and secret access key. These can be created in the AWS Management Console through the IAM (Identity and Access Management) section.
    - Go to the IAM dashboard in your AWS account.
    - Navigate to 'Users' and select your user or create a new one.
    - Under the 'Security credentials' tab, create a new access key.
    - Download the key file or note the access key ID and secret access key.

3. **Configure AWS CLI:** It’s recommended to install and configure the AWS CLI with the access keys, as Terraform can automatically use the credentials from the AWS CLI configuration file.
    - Install the AWS CLI.
    - Configure it by running `aws configure` in your terminal and input your access key ID, secret access key, default region, and output format.
        - You can either hard code your access key and secret in providers.tf as such:
                `provider "aws" {
                    region     = "us-west-2" // this line is already provided for you
                    access_key = "your-access-key-id"
                    secret_key = "your-secret-access-key"
                }`
        - Or you can set the public and secret in your environment variables as such:
                    `export AWS_ACCESS_KEY_ID="your-access-key-id"
                    export AWS_SECRET_ACCESS_KEY="your-secret-access-key"`



4. **Initialize Terraform:** Navigate to your Terraform project directory in your command line tool and run `terraform init`. This command will initialize Terraform and download the necessary provider plugins. 

5. Don't forget to add a db_password variable in variables.tf file and define in another file that you DO NOT commit (*terraform.auto.tfvars*). 
6. Also, don't foreget to add `/ssh-keys` folder to your root directory. Instructions in **Prerequisites** section

6. **Plan and Apply:** Run `terraform plan` to see the changes that Terraform will make to your AWS infrastructure, and terraform apply to apply those changes.

## I Just Want to Code
1. Fork and then clone this repository to your local machine.
2. Configure and Run Terraform for your AWS account so that you have a basic backend built. Once you have your infrastructure built you can start coding your backend. 
3. You'll find index.js in the `/src` folder. This is the entry point of your backend and it will be mapped to a Lambda called "main-lambda".
4. You can directly code within Lambda or feel free to upload a .zip of your project into the "main-lambda-bucket" S3 bucket.
5. The API to connect your front end to your back end can be found in the API Gateway. Feel free to play around and create yourself a more robust API with more resources & methods.

So 2 takeaways really:
- Code in Lambda
- Connect with API Gateway

HAPPY CODING!


## Provisioned AWS Resources (Detailed):

### 1. VPC (terraform/vpc.tf)
The `aws_vpc.main_vpc` is like the foundation of a private space in the cloud where you can place all your project's resources. It's set up with a large enough network to support many different resources and is configured to work well with web services. It's labeled main_vpc for easy identification.

The `aws_internet_gateway.main_vpc_gateway` acts as the door between the private space of your VPC and the wider internet. This lets the resources inside the VPC send and receive data to and from the internet.

The code also defines two pairs of subnets `public_subnet` and `private_subnet`

Subnets subdivide your private space into smaller, more manageable sections. A `public_subnet` is like the front yard, visible and accessible from the internet. A `private_subnet` is like your backyard. They're not directly accessible from the internet, providing more security for sensitive tasks
 
`subnet_a` and `subnet_b` are  set up in two different locations (zones) for better performance and reliability. The `aws_route_table.main_vpc_public_routetable` is a set of rules that determines how traffic from the public subnets can go to the internet, using the internet gateway.

### 2. EC2 (terraform/ec2.tf)
The aws_instance.web is like a virtual computer in the cloud. It's set up with a basic configuration (t2.micro) that balances cost and performance for small-scale applications.

This virtual computer will be placed in the public section of your cloud space (public_subnet_a), allowing it to communicate with the internet. It's prepared to use a security checklist (`aws_security_group.ec2_securitygroup.id`) to ensure only safe and specified traffic can come and go.

It uses a key, `aws_key_pair.rds_connector_key.key_name`, for secure access. It’s tagged with the name db-client, so you know that you can potentially use the EC2 to hook into your database.

If you want to SSH into your EC2 from your local terminal, be sure to create a folder named `/ssh-keys` and run the following command:

`ssh-keygen -t rsa -b 2048 -f my_key_pair`

This command generates two files: my_key_pair (private key) and my_key_pair.pub (public key) **DO NOT COMMIT THESE**


Once you have these two files, using your terminal cd into the`/ssh-keys` folder and run this command:

`chmod 400 my_key_pair` 

This command will make sure you have the private key (my_key_pair) on your local machine and that its permissions are set correctly

While in the same `/ssh-keys` folder, use this command to access your provisioned EC2 instance: **(be sure to put your ec2-ip address between `<>`. Also delete the `<>` after pasting your ec2-ip address)**

`ssh -i "my_key_pair" ec2-user@<your-ec2-ip-address>`

Once you see something like this: `ubuntu@ip-xx-x-x-xx:~$` then you know you've successfully connected to your EC2 instance. You can also use Cloud 9 to connect to your EC2 instance.

### 3. RDS-PostgreSQL (terraform/rds.tf)

The aws_db_instance.default creates a managed database server using Amazon's Relational Database Service (RDS) with 20 GB of storage.

The database runs PostgreSQL version 15.3, a modern, powerful SQL database system, on a small instance (db.t4g.micro), suitable for low to moderate workloads.

The `aws_db_subnet_group.main_vpc_subnet_group` is essentially a grouping of private zones in your cloud space where a database can securely reside. It uses the private subnet defined in the VPC section above. This means the database will sit in a secure area not directly accessible from the internet. This setup enhances security by isolating the database from public access.

The database is ready for setup with a username, `test_main_dbuser`, but you’ll need to add a password for secure access. 

The easiest way to access your database is to download a database client tool like pgAdmin. 

### 4. API Gateway (terraform/apigateway.tf)

`main_lambda_api` is the gateway for your Lambda function, enabling it to be triggered via HTTP requests (GET, POST, etc). The API defines a public GET method at the API's root path, allowing anyone to access it without authentication.

`main_lambda_integration` connects the GET method to your Lambda function and `apigw_lambda_permission` grants the API Gateway permission to invoke your Lambda function. These two combined allow your front end to interact with your back end.

The API is then deployed with the GET method in a dev stage, making it available for use.

### 5. Lambda (terraform/lambda.tf)

A serverless function called `main-lambda` is set up to run Node.js code stored in S3, with permissions to execute and log activities. CloudWatch captures and stores the Lambda function's logs for two weeks.

You'll notice in the `/src` folder that there is the index.js file. This is the entry point into your backend. All front-end requests will travel from the API gateway and hit the index.js file first. This is where you can start coding your backend code. 
