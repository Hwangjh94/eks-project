resource "aws_security_group" "rds" {
  name        = "rds-security-group"
  description = "Allow MySQL traffic from EKS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group"
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "RDS subnet group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "eks-mysql-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = "admin"
  password               = "YourStrongPassword123!" # 실제 환경에서는 변수 또는 Secrets Manager 사용 권장
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = "default.mysql8.0"
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "eks-mysql-db"
  }
}

output "db_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "db_username" {
  value = aws_db_instance.mysql.username
}
