variable "region" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "account" {
  type = number
}

variable "secret_id" {
  type = string
}

variable "subnet_group_id" {
  type = string
}

variable "rds_sg" {
  type = string
}
variable "data_lake_bucket" {
  type = string
}


variable "glue_database_name" {
  type = string
}

variable "etlsrciptbucket" {
  type = string
}


variable "script" {
  type = string
}

variable "glue_crawler_name" {
  type = string
}

variable "gluejobName" {
  type = string
}
variable "glue_worflow_name" {
  type = string
}

variable "glue_crawler_trigger_name" {
  type = string
}
variable "glue_job_trigger_name" {
  type = string
}

variable "data_source_paths" {
    type = list(string)
}

variable "environment" {
  type = string
}
