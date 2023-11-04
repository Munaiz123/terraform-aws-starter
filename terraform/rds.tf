resource "aws_db_subnet_group" "main_vpc_subnet_group" {
  name = "main_vpc_subnet_group"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}


resource "aws_db_instance" "default" {

  allocated_storage    = 20
  identifier           = "test-database"
  storage_type         = "gp3"
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t4g.micro"
  username             = "test_main_dbuser"
  password             = "" # add password but commit
  parameter_group_name = "default.postgres15"
  db_subnet_group_name = aws_db_subnet_group.main_vpc_subnet_group.name

  vpc_security_group_ids = [aws_security_group.allow_rds.id]
  skip_final_snapshot  = true
}

