resource "aws_cloudfront_origin_access_control" "rm_feature_toggle_cloudfront_acl" {
  name                              = "s3featuresconfigpolicyacl"
  description                       = "Default Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "rm_feature_toggle_cdn_distribution" {
  origin {
    domain_name              = aws_s3_bucket.rm_feature_toggle_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.rm_feature_toggle_cloudfront_acl.id
    origin_id                = aws_s3_bucket.rm_feature_toggle_bucket.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.rm_feature_toggle_bucket.id

    response_headers_policy_id = aws_cloudfront_response_headers_policy.rm_feature_toggle_cdn_distribution_cors.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_response_headers_policy" "rm_feature_toggle_cdn_distribution_cors" {
  name    = "cors-features-policy"
  comment = "CORS Policy for OFE CDN Distribution"

  cors_config {
    access_control_allow_credentials = false

    access_control_allow_headers {
      items = ["*"]
    }

    access_control_allow_methods {
      items = ["GET"]
    }

    access_control_allow_origins {
      items = ["*"]
    }

    origin_override = true
  }
}
