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

variable "subnets" {
  type = list(string)
}

variable "rds_sg" {
  type = string
}
variable "data_lake_bucket" {
  type = string
}

variable "environment" {
  type = string
}
