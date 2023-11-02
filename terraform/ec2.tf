resource "aws_instance" "RDS_client" {
  ami                  = "ami-0fc5d935ebf8bc3bc"
  instance_type        = "t2.micro"
  availability_zone    = "us-east-1a"
  associate_public_ip_address = true
  # other configurations...
}
