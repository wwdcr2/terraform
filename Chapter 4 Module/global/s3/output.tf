output "s3_bucket_arn"{
  value = aws_s3_bucket.terraform_state.arn
}
output "dynamo_arn"{
  value = aws_dynamodb_table.terraform_lock.arn
}