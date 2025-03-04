resource "aws_s3_bucket" "s3_logs" {
  bucket = "s3-logs-bucket"
  tags   = { Name = "s3_logs" }
}

resource "aws_s3_bucket" "s3_static" {
  bucket = "s3-static-content"
  tags   = { Name = "s3_static" }
}