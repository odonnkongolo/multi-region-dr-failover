# Generate a random ID to ensure global bucket name uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# -------------------------------------------------------------------------
# PRIMARY REGION: IRELAND (eu-west-1)
# -------------------------------------------------------------------------
resource "aws_s3_bucket" "primary" {
  bucket        = "dr-primary-never404-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "primary" {
  bucket = aws_s3_bucket.primary.id
  index_document { suffix = "index.html" }
}

resource "aws_s3_bucket_public_access_block" "primary" {
  bucket = aws_s3_bucket.primary.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "primary" {
  bucket = aws_s3_bucket.primary.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.primary.arn}/*"
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.primary]
}

# -------------------------------------------------------------------------
# BACKUP REGION: LONDON (eu-west-2)
# -------------------------------------------------------------------------
resource "aws_s3_bucket" "backup" {
  # We invoke the London alias here to push this to the UK data center
  provider      = aws.london
  bucket        = "dr-backup-never404-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "backup" {
  provider = aws.london
  bucket   = aws_s3_bucket.backup.id
  index_document { suffix = "index.html" }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  provider = aws.london
  bucket   = aws_s3_bucket.backup.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "backup" {
  provider = aws.london
  bucket   = aws_s3_bucket.backup.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.backup.arn}/*"
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.backup]
}

# Outputs so we can easily click the URLs
output "primary_website_url" {
  value = aws_s3_bucket_website_configuration.primary.website_endpoint
}

output "backup_website_url" {
  value = aws_s3_bucket_website_configuration.backup.website_endpoint
}