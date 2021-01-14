locals {
  # Requires S3 Access
  # https://docs.amazonaws.cn/en_us/dms/latest/userguide/CHAP_Target.S3.html#CHAP_Target.S3.Prerequisites
  iam_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${var.data_lake_bucket}"
        },
        {
            "Effect": "Allow",
            "Action": "rds:*",
            "Resource": "arn:aws:rds:${var.region}:${var.account}:db:${local.secrets["rds_name"]}"
        },
        {
            "Action": [
                "cloudformation:CreateChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:DescribeStackResource",
                "cloudformation:DescribeStacks",
                "cloudformation:ExecuteChangeSet",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "kms:DescribeKey",
                "kms:ListAliases",
                "kms:ListKeys",
                "lambda:ListFunctions",
                "rds:DescribeDBClusters",
                "rds:DescribeDBInstances",
                "tag:GetResources"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
  }
  EOF
}