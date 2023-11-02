resource "aws_db_instance" "main_postgres_db" {
  allocated_storage    = 20
  storage_type         = "gp3"
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t4g.micro"
  db_name              = "main_postgres_db"
  username             = "main_db_user"

  password             = "" # Be cautious with hardcoded passwords.
  parameter_group_name = "default.postgres15"
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main.id]

  skip_final_snapshot  = true
  multi_az = false
  tags = {}
  
}


resource "aws_db_instance" "main_postgres_db_readonly" {
  allocated_storage     = 20
  storage_type          = "gp3"
  engine                = "postgres"
  engine_version        = "15.3"
  instance_class        = "db.t4g.micro"

  password              = "" # Be cautious with hardcoded passwords.
  parameter_group_name  = "default.postgres15"
  
  replicate_source_db   = aws_db_instance.main_postgres_db.db_name
  db_subnet_group_name = aws_db_subnet_group.main.name

  skip_final_snapshot   = true
  multi_az = false
  tags = {}
}
