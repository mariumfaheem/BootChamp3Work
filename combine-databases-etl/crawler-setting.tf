locals {
  crawler_configuration = <<EOF
{
    "Version": 1.0,
    "CrawlerOutput": {
      "Tables": { "AddOrUpdateBehavior": "MergeNewColumns" }
    }
  }
EOF
}