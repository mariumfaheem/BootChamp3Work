//fetching secret key
data "aws_secretsmanager_secret" "secrets" {
  arn = "arn:aws:secretsmanager:${var.region}:${var.account}:secret:${var.secret_id}"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}

locals {
  secrets = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)
  s3_settings="addColumnName=true;bucketName=${var.data_lake_bucket};compressionType=NONE;dataFormat=parquet;datePartitionEnabled=false;encodingType=plain-dictionary;includeOpForFullLoad=true;parquetTimestampInMillisecond=true;"
}

# Role
resource "aws_iam_role" "bazaar_rds_dms_role" {
  name = "${var.environment}_bazaar_rds_dms_role"
  path = "/etl/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "dms.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "bazaar_rds_dms_profile" {
  name = "${var.environment}_bazaar_rds_dms_profile"
  role = aws_iam_role.bazaar_rds_dms_role.name
}

resource "aws_iam_role_policy" "bazaar_rds_dms_policy"{
  name = "${var.environment}_bazaar_rds_dms_policy"
  role = aws_iam_role.bazaar_rds_dms_role.id
  policy = local.iam_policy
}

# Source Endpoint
resource "aws_dms_endpoint" "source" {
  endpoint_id                 = "${var.environment}-bazaar-rds-src-endpoint"
  endpoint_type               = "source"
  engine_name                 = "mysql"
  server_name                 = local.secrets["server_name"]
  username                    = local.secrets["username"]
  password                    = local.secrets["password"]
  port                        = local.secrets["port"]
  tags = {
    service = "data-lake"
  }
}

# Destination Endpoint
resource "aws_dms_endpoint" "destination" {
  endpoint_id                 = "${var.environment}-bazaar-s3-dest-endpoint"
  endpoint_type               = "target"
  engine_name                 = "s3"
  extra_connection_attributes = "addColumnName=true;bucketName=${var.data_lake_bucket};compressionType=NONE;dataFormat=parquet;datePartitionEnabled=false;encodingType=plain-dictionary;includeOpForFullLoad=true;parquetTimestampInMillisecond=true;"

  s3_settings {
    service_access_role_arn   = aws_iam_role.bazaar_rds_dms_role.arn
    bucket_name               = var.data_lake_bucket
  }

  tags = {
    service = "data-lake"
  }
}

# Replication Instance
resource "aws_security_group" "dms_sg" {
  name   = "${var.environment}-dms-rds-datalake-bazaar-sg"
  vpc_id = var.vpc_id

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.rds_sg]
    description     = "Allow all traffic to RDS port"
  }

  tags               = {
    environment      = var.environment
    uses_iac         = true
    iac_provider     = "terraform"
  }
}

resource "aws_dms_replication_subnet_group" "subnet_group" {
  replication_subnet_group_description = "Bazaar RDS Replication subnet group"
  replication_subnet_group_id          = "${var.environment}-dms-bazaar-subnet-group"

  subnet_ids = var.subnets

  tags = {
    service = "data-lake"
  }
}

# Create a new replication instance
resource "aws_dms_replication_instance" "replication_instance" {
  replication_instance_id      = "${var.environment}-dms-bazaar-rds-dms-instance"
  apply_immediately            = false
  multi_az                     = false
  publicly_accessible          = false
  engine_version               = "3.4.3"
  auto_minor_version_upgrade   = true
  allocated_storage            = 50
  replication_instance_class   = "dms.t3.small"

  preferred_maintenance_window = "sun:10:30-sun:14:30"

  replication_subnet_group_id  = aws_dms_replication_subnet_group.subnet_group.id
  vpc_security_group_ids = [ aws_security_group.dms_sg.id ]

  tags = {
    service = "data-lake"
  }
}

# DMS Task
# Create a new replication task
resource "aws_dms_replication_task" "replication_task" {
  replication_task_id       = "${var.environment}-dms-bazaar-rds-replication-task"
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.replication_instance.replication_instance_arn
  source_endpoint_arn       = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.destination.endpoint_arn

  replication_task_settings = jsonencode(local.replication_settings)

  table_mappings = jsonencode(local.table_mappings)

  tags = {
    service = "data-lake"
  }
}


