resource "aws_s3_bucket" "tf_state" {
  bucket = var.tfstate_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encrypt" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# resource "aws_dynamodb_table" "tf_lock" {
#   name           = "terraform-state-lock"
#   hash_key       = "LockID"
#   billing_mode   = "PAY_PER_REQUEST"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }