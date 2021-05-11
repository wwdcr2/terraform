terraform {
  backend "s3"{
    bucket = "terraform-state-cloudest"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    #dynamodb_table = "terraform-state-cloudest"
  }
}