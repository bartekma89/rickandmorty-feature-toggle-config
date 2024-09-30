resource "aws_s3_bucket" "rm_feature_toggle_bucket" {
  bucket = var.features_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "rm_feature_toggle_bucket_ownership" {
  bucket = aws_s3_bucket.rm_feature_toggle_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "rm_feature_toggle_bucket_access" {
  bucket = aws_s3_bucket.rm_feature_toggle_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "rm_feature_toggle_cloudfront_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.rm_feature_toggle_bucket_ownership,
    aws_s3_bucket_public_access_block.rm_feature_toggle_bucket_access,
  ]

  bucket = aws_s3_bucket.rm_feature_toggle_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "rm_feature_toggle_bucket_policy" {
  bucket = aws_s3_bucket.rm_feature_toggle_bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${var.features_bucket_name}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "rm_toggle_website_configuration" {
  bucket = aws_s3_bucket.rm_feature_toggle_bucket.id

  index_document {
    suffix = "index.html"
  }
}
