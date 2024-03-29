resource "aws_db_subnet_group" "rds_eu-central-1" {
  provider = aws.eu-central-1
  name     = "rds"
  subnet_ids = [
    aws_default_subnet.eu-central-1a.id,
    aws_default_subnet.eu-central-1b.id,
    aws_default_subnet.eu-central-1c.id,
  ]
}

resource "aws_security_group" "rds_eu-central-1" {
  provider = aws.eu-central-1
  name     = "rds"
  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "rds" }
}

resource "aws_db_instance" "rds_eu-central-1" {
  provider   = aws.eu-central-1
  identifier = "rds"

  instance_class        = var.rds_instance_config["${local.environment}_eu-central-1"].instance_class
  allocated_storage     = var.rds_instance_config["${local.environment}_eu-central-1"].allocated_storage
  max_allocated_storage = var.rds_instance_config["${local.environment}_eu-central-1"].max_allocated_storage
  storage_type          = var.rds_instance_config["${local.environment}_eu-central-1"].storage_type

  engine               = "postgres"
  engine_version       = "14.5"
  parameter_group_name = "default.postgres14"

  username                            = "postgres"
  password                            = data.aws_kms_secrets.sops_eu-central-1.plaintext["rds_root"]
  iam_database_authentication_enabled = true

  db_subnet_group_name   = aws_db_subnet_group.rds_eu-central-1.name
  vpc_security_group_ids = [aws_default_security_group.eu-central-1.id, aws_security_group.rds_eu-central-1.id]
  publicly_accessible    = true

  backup_retention_period               = var.rds_instance_config["${local.environment}_eu-central-1"].backup_retention_period
  monitoring_interval                   = 60
  monitoring_role_arn                   = aws_iam_role.rds_enhanced_monitoring.arn
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  deletion_protection = true
}
