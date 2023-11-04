resource "aws_instance" "web" {
  ami           = "ami-0fc5d935ebf8bc3bc"  # Replace with a valid AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_a.id
  vpc_security_group_ids = [aws_security_group.ec2_securitygroup.id]
  key_name = aws_key_pair.rds_connector_key.key_name

  tags = {
    Name = "db-client"
  }
}

resource "aws_key_pair" "rds_connector_key" {
    key_name = "rds_connector_key"
    public_key = file("../ssh-keys/my_key_pair.pub")
  
}


resource "aws_security_group" "allow_rds" {
  name        = "allow_rds"
  description = "Allow inbound traffic from EC2"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_securitygroup.id]
  }  
}


resource "aws_security_group" "ec2_securitygroup" {
  name        = "ec2_sg"
  description = "Allow inbound traffic from Internet to EC2"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }   

}