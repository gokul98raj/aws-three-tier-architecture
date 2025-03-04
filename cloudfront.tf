resource "aws_cloudfront_distribution" "cf_main" {
  origin {
    domain_name = aws_s3_bucket.s3_static.bucket_regional_domain_name
    origin_id   = "aws_s3_bucket.s3_static.id"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for static content"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "aws_s3_bucket.s3_static.id"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 18000
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "main_cloudfront"
  }
}

resource "aws_cloudfront_origin_access_identity" "cf_oai" {
  comment = "OAI for main_cloudfront"
}

resource "aws_s3_bucket_policy" "s3_static_policy" {
  bucket = aws_s3_bucket.s3_static.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.cf_oai.id}"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.s3_static.arn}/*"
      }
    ]
  })
}