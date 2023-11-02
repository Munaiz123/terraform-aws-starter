resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "main_subnet"
  }
}

resource "aws_db_subnet_group" "main" {
  name = "main_db_subnet_group"
  subnet_ids = [aws_subnet.main.id]
}

resource "aws_security_group" "main" {
  name = "main_security_group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # It's better to restrict this to your IP range
  }
}