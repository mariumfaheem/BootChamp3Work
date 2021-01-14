region = "us-east-2"
account = 774337928902
secret_id = "testing/databasedst-9PmGQH"
data_lake_bucket = "alldatabasesdestination"
environment = "sandbox"
rds_sg = "sg-53fe8a2d"
vpc_id = "vpc-598a3b32"
subnet_group_id = "default-vpc-598a3b32"
access_key="AKIA3ISRDD3DB52KDJB2"
secret_key="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"
script="combinescriptname"
etlsrciptbucket="prod-etl-script-for-merge-databases"



//Glue
crawler_name="crawler_name"
glue_worflow_name="f1"
glue_crawler_name="g1"
glue_database_name="s1"
gluejobName="combinescript1"
data_source_paths=["s3://alldatabasesdestination/bazaar_agent/visit_log","s3://alldatabasesdestination/bazaar_catalog/category",
   "s3://alldatabasesdestination/bazaar_catalog/category_hierarchy","s3://alldatabasesdestination/bazaar_catalog/category_product",
  "s3://alldatabasesdestination/bazaar_catalog/product","s3://alldatabasesdestination/bazaar_catalog/product_variant",
  "s3://alldatabasesdestination/bazaar_catalog/product_variant_inventory","s3://alldatabasesdestination/bazaar_customer/store",
  "s3://alldatabasesdestination/bazaar_customer/store_address","s3://alldatabasesdestination/bazaar_customer/store_user",
  "s3://alldatabasesdestination/bazaar_identity/client","s3://alldatabasesdestination/bazaar_identity/role",
  "s3://alldatabasesdestination/bazaar_identity/user","s3://alldatabasesdestination/bazaar_identity/user_session",
  "s3://alldatabasesdestination/bazaar_order/order","s3://alldatabasesdestination/bazaar_order/order_attachment",
  "s3://alldatabasesdestination/bazaar_order/order_attribute","s3://alldatabasesdestination/bazaar_order/order_customer",
  "s3://alldatabasesdestination/bazaar_order/order_event","s3://alldatabasesdestination/bazaar_order/order_item",
  "s3://alldatabasesdestination/bazaar_order/order_item_shipment","s3://alldatabasesdestination/bazaar_order/order_item_warehouse",
  "s3://alldatabasesdestination/bazaar_order/order_payment","s3://alldatabasesdestination/bazaar_order/order_pricing_breakdown",
  "s3://alldatabasesdestination/bazaar_order/order_webhook_request"]

glue_crawler_trigger_name="triggercrawler"
glue_job_trigger_name="triggerjob"
