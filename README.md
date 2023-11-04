# Terraform AWS Starter

### Welcome to the repo

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


## How to Run Terraform
1. Download Terraform CLI
2. `git clone` this repository
3. Download Access Key & Secret from your AWS account
    - IAM -> Security Credentials: set Key & Secret in env Variables or in provider.tf **(not recomended**) as such:  

provider "aws" {
  region     = "us-west-1"
  access_key = "YOUR_AWS_ACCESS_KEY"
  secret_key = "YOUR_AWS_SECRET_KEY"
}  

**NOTE: Do NOT commit provider.tf if you're hard coding it in provider.tf**

**A better way to handle access/secret key is to add them to env variables. The method shown above is a temporary quickway to connect your terrform to aws account so that you can provision resources quickly**

4. Run `terraform init` 
5. Set your db password on line 17 of rds.tf 
6. Run `terraform apply` -> 'yes' to confirm

After sometime you should have the following AWS Services provisioned in your AWS account:


## Provisioned AWS Resources (Detailed):

### 1. VPC (terraform/vpc.tf)
The `aws_vpc.main_vpc` is like the foundation of a private space in the cloud where you can place all your project's resources. It's set up with a large enough network to support many different resources and is configured to work well with web services. It's labeled main_vpc for easy identification.

The `aws_internet_gateway.main_vpc_gateway` acts as the door between the private space of your VPC and the wider internet. This lets the resources inside the VPC send and receive data to and from the internet.

The code also defines two pairs of subnets `public_subnet` and `private_subnet`

Subnets subdivide your private space into smaller, more manageable sections. A `public_subnet`is like the front yard, visible and accessible from the internet. A `private_subnet` is like your backyard. They're not directly accessible from the internet, providing more security for sensitive tasks
 
`subnet_a` and `subnet_b` are  set up in two different locations (zones) for better performance and reliability. The `aws_route_table.main_vpc_public_routetable` is a set of rules that determines how traffic from the public subnets can go to the internet, using the internet gateway.

### 2. EC2 (terraform/ec2.tf)
The aws_instance.web is like a virtual computer in the cloud. It's set up with a basic configuration (t2.micro) that balances cost and performance for small-scale applications.

This virtual computer will be placed in the public section of your cloud space (public_subnet_a), allowing it to communicate with the internet. It's prepared to use a security checklist (`aws_security_group.ec2_securitygroup.id`) to ensure only safe and specified traffic can come and go.

It uses a key, `aws_key_pair.rds_connector_key.key_name`, for secure access. It’s tagged with the name db-client, so you know that you can potentially use the EC2 to hook into your database.

If you want to SSH into your EC2 from your local terminal, be sure to create a folder named `/ssh-keys` and run the following command:

`ssh-keygen -t rsa -b 2048 -f my_key_pair`

This command generates two files: my_key_pair (private key) and my_key_pair.pub (public key) **DO NOT COMMIT THESE**


Once you have these two files, using your terminal cd into `/ssh-keys` folder and run this command:

`chmod 400 my_key_pair` 

This command will make sure you have the private key (my_key_pair) on your local machine and that its permissions are set correctly

While in the same `/ssh-keys` folder, use this command to access your provisioed EC2 instance: **(besure to put your ec2-ip address between `<>`. Also delete the `<>` after pasting your ec2-ip address)**

`ssh -i "my_key_pair" ec2-user@<your-ec2-ip-address>`

Once you see something like this: `ubuntu@ip-xx-x-x-xx:~$` then you know you've succesfully connected to your EC2 instance. You can also use Cloud 9 to connect to your EC2 instance.

### 3. RDS-PostgreSQL (terraform/rds.tf)

The aws_db_instance.default creates a managed database server using Amazon's Relational Database Service (RDS) with 20 GB of storage.

The database runs PostgreSQL version 15.3, a modern, powerful SQL database system, on a small instance (db.t4g.micro), suitable for low to moderate workloads.

The `aws_db_subnet_group.main_vpc_subnet_group` is essentially a grouping of private zones in your cloud space where a database can securely reside. It uses the private subnet defined in the VPC section above. This means the database will sit in a secure area not directly accessible from the internet. This setup enhances security by isolating the database from public access.

The database is ready for setup with a username, `test_main_dbuser`, but you’ll need to add a password for secure access. 

The easiest way to access your database is to download a database client tool like pgAdmin. 

### 4. API Gateway (terraform/apigateway.tf)

`main_lambda_api` is the gateway for your Lambda function, enabling it to be triggered via HTTP requests (GET, POST, etc). The API defines a public GET method at the API's root path, allowing anyone to access it without authentication.

`main_lambda_integration` connects the GET method to your Lambda function and `apigw_lambda_permission` grants the API Gateway permission to invoke your Lambda function. These two combined allows your front end to interact with your backend.

The API is then deployed with the GET method in a dev stage, making it available for use.

### 5. Lambda (terraform/lambda.tf)

A serverless function called `main-lambda` is set up to run Node.js code stored in S3, with permissions to execute and log activities. CloudWatch captures and stores the Lambda function's logs for two weeks.

You'll notice in the `/src` folder that there is the index.js file. This is the entry point into your backend. All front end requests will travel from the API gateway and hit the index.js file first. This is where you can start coding your backend code. 
