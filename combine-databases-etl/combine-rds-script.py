# essential libraries
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import boto3
import base64
from pyspark.sql import types
from pyspark.sql.functions import col
from awsglue.dynamicframe import DynamicFrame
import pymysql
import json

pymysql.install_as_MySQLdb()
import MySQLdb


## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ["JOB_NAME"])

# s3 data bucket config
AWS_REGION = "us-east-2"
GLUE_DATABASE = "s1"
TARGET_FORMAT = "parquet"

SECRET_NAME = "testing/databasedst"
region_name = AWS_REGION

# Create a Secrets Manager client
session = boto3.session.Session()
client = session.client(
    service_name='secretsmanager',
    region_name=region_name
)

get_secret_value_response = client.get_secret_value(
  SecretId=SECRET_NAME
)

# extracting secrets
secrets_str = get_secret_value_response['SecretString']
secrets = json.loads(secrets_str)

#Fetching value from secret-manager
db_username = secrets.get('username')
db_password = secrets.get('password')
db_rdshost = secrets.get('rds_host')
db_port = secrets.get("port")
db_rdsdatabasename = secrets.get('rds_databasename')


#RDS Connection config
RDS_HOST = db_rdshost
RDS_USER = db_username
RDS_PORT = db_port
RDS_PASSWORD = db_password
RDS_DATABASENAME =db_rdsdatabasename
print(RDS_PORT)
# SPARK CONTEXT
spark_context = SparkContext()
glue_context = GlueContext(spark_context)
spark = glue_context.spark_session
job = Job(glue_context)
job.init(args["JOB_NAME"], args)
s3 = boto3.client("s3")

# Glue connection to destionation RDS
db = MySQLdb.connect(
    host=RDS_HOST,
    port=int(RDS_PORT),
    user=RDS_USER,
    password=RDS_PASSWORD,
    db=RDS_DATABASENAME,
)
cursor = db.cursor()
print(RDS_HOST,RDS_PORT)
# Main
client = boto3.client(service_name="glue", region_name=AWS_REGION)
response = client.get_tables(DatabaseName=GLUE_DATABASE)
tables = response["TableList"]
for table_meta in tables:
    table = table_meta["Name"]

    glue_dynamic_frame = glue_context.create_dynamic_frame.from_catalog(
        database=GLUE_DATABASE,
        table_name=table,
        additional_options={"mergeSchema": "true"},
    )
    print("##############"+table+"#################")
    # all column from glue catalog
    all_cols = [
        col["Name"].lower() for col in table_meta["StorageDescriptor"]["Columns"]
    ]

    # glue to spark dataframe conversion
    glue_dynamic_frame = glue_dynamic_frame.toDF()

    # spark table creation for query
    glue_dynamic_frame.createOrReplaceTempView(table)

    cursor.execute("DROP TABLE IF EXISTS `{x}`".format(x=table))

    if "op" in all_cols:
        query = """select {x}
      from (
        select *, row_number() over(partition by id order by updated_at desc, Op asc) rrn
        from {y}
      ) a
      where rrn = 1
      and (op is null or op <> 'D')""".format(
            x=", ".join(all_cols), y=table
        )

    else:
        # if Op is not in rds so following query will create op first it will check op is exist or not
        query = """select {x}
      from (
        select *, row_number() over(partition by id order by updated_at desc) rrn
        from {y}
      ) a
      where rrn = 1""".format(
            x=", ".join(all_cols), y=table
        )

    results_df = spark.sql(query)

    # exception handling for tinyint
    for dtype in results_df.dtypes:
        if dtype[1] == "tinyint":
            results_df = results_df.withColumn(
                dtype[0], col(dtype[0]).cast(types.StringType())
            )

    # Converting park frame into gluecontext for dynamicframe
    results_dynamic_frame = DynamicFrame.fromDF(
        results_df, glue_context, "results_dynamic_frame"
    )

    # For Glue Connection of RDS
    connection_options = {
        "url": "jdbc:mysql://{host}:{port}/{db_name}".format(
            host=RDS_HOST, port=RDS_PORT, db_name=RDS_DATABASENAME
        ),
        "dbtable": table,
        "user": RDS_USER,
        "password": RDS_PASSWORD,
    }
    print("##############"+table+"#################")
    print(connection_options)
    # Writing into glue dataframe
    datasink = glue_context.write_dynamic_frame.from_options(
        frame=results_dynamic_frame,
        connection_type="mysql",
        connection_options=connection_options,
        transformation_ctx="datasink"
    )

# Rds cursor close
cursor.close()
db.commit()

# Rds db close
db.close()
del cursor
job.commit()
