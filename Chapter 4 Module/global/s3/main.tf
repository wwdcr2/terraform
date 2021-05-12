resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-state-cloudest"
    force_destroy = true

    versioning {
        enabled = true
    }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name = "terraform-state-cloudest"
  hash_key = "LockID"
  read_capacity = 2
  write_capacity = 2

  attribute {
    name = "LockID"
    type = "S"
  }
}