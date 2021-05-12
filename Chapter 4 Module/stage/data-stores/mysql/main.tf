provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "example"{
    engine               = "mysql"
    allocated_storage    = 10
    instance_class       = "db.t2.micro"
    name                 = "example_database"
    username             = "admin"
    password             = var.db_password
}

terraform {
  backend "s3" {
    bucket = "terraform-state-cloudest"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
#    dynamodb_table = "(생성한 DynamoDB 테이블 이름)"
  }
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webservers-prod"
  db_remote_state_bucket = "tf-start-stage"
  db_remote_state_key = "prod/data-stores/mysql/terrform.tfstate"
  
}