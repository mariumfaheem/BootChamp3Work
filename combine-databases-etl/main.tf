data "aws_secretsmanager_secret" "secrets" {
  arn = "arn:aws:secretsmanager:${var.region}:${var.account}:secret:${var.secret_id}"
}


data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}


locals {
  secrets = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)
}


resource "aws_iam_role" "ETL_role" {
  name = "${var.environment}_ETL_role"
  path = "/crawler/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


# ETL Role
resource "aws_iam_instance_profile" "ETL_profile" {
  name = "${var.environment}_ETL_profile"
  role = aws_iam_role.ETL_role.name
}


# ETL policy
resource "aws_iam_role_policy" "ETL_policy" {
  name = "${var.environment}_ETLs_policy"
  role = aws_iam_role.ETL_role.id
  policy = local.iam_policy
}

# Create a bucket
resource "aws_s3_bucket" "etl-script-for-merge-databases" {
  bucket ="${var.etlsrciptbucket}"
  acl    = "public-read"   # or can be "public-read"
  tags = {

    Name        = "prod-etl-script-for-merge-databases"

    Environment = "Dev"

  }

}

# Upload an object
resource "aws_s3_bucket_object" "s3_script_location" {

  bucket = aws_s3_bucket.etl-script-for-merge-databases.id
  key    = "profile"
  acl    = "private"  # or can be "public-read"
  source = "combine-rds-script.py"
  content_type  = ".py"
  etag = filemd5("combine-rds-script.py")

}

//Glue catalog name completed
resource "aws_glue_catalog_database" "Merge_catalog_database" {
  name = "${var.glue_database_name}"
}

//glue crawler completed
resource "aws_glue_crawler" "glue-crawler" {
  database_name = aws_glue_catalog_database.Merge_catalog_database.name
  name          = "${var.glue_crawler_name}"
  role          = aws_iam_role.ETL_role.arn
  dynamic "s3_target" {
    for_each = "${var.data_source_paths}"
    content {
      path = s3_target.value
    }
  }
  configuration =local.crawler_configuration
}

//glue workflow
resource "aws_glue_workflow" "dhw-workflow" {
  name = "${var.glue_worflow_name}"
}

//glue job crwaler
resource "aws_glue_trigger" "trigger-to-crawler" {
  name          = var.glue_crawler_trigger_name
  schedule = "cron(12 02 * * ? *)"
  type     = "SCHEDULED"
  workflow_name = aws_glue_workflow.dhw-workflow.name
  actions {
    crawler_name= var.glue_crawler_name
  }
}


//glue trigger for job complete
resource "aws_glue_trigger" "trigger-to-Job" {
  name = var.glue_job_trigger_name
  type = "CONDITIONAL"
  workflow_name = aws_glue_workflow.dhw-workflow.name

  actions {
    job_name = aws_glue_job.dhw-ETL-script.name
  }

  predicate {
    conditions {
      crawler_name = aws_glue_crawler.glue-crawler.name
      crawl_state  = "SUCCEEDED"
    }
  }
}

//glue job completed
resource "aws_glue_job" "dhw-ETL-script" {
  name     = "CombineScript"
  role_arn = aws_iam_role.ETL_role.arn

  command {
    python_version="3"
    script_location ="s3://${aws_s3_bucket_object.s3_script_location.bucket}/profile"
  }
  glue_version="2.0"
  number_of_workers="10"
  worker_type="G.1X"
  default_arguments = {
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" ="true"
  }

}

