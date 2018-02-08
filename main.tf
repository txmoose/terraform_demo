variable "secret_key" {}
variable "access_key" {}
variable "cf_email" {}
variable "cf_token" {}

# Configure aws with a default region
provider "aws" {
  secret_key = "${var.secret_key}"
  access_key = "${var.access_key}"
  region = "us-east-1"
}

# Configure CloudFlare provider
provider "cloudflare" {
  email = "${var.cf_email}"
  token = "${var.cf_token}"
}

# Create a demo s3 bucket
resource "aws_s3_bucket" "dev-txmoose-com" {
  bucket = "dev.txmoose.com"
  acl = "public-read"
  policy = "${file("policy.json")}"

  website {
    index_document = "index.html"
  }

  tags {
    Name = "Terraform Demo for Moose"
    Environment = "Prod"
    TF = "yes"
    Website = "yes"
  }
}

# Upload object to our bucket
resource "aws_s3_bucket_object" "object" {
  bucket = "${aws_s3_bucket.dev-txmoose-com.id}"
  key = "index.html"
  source = "./index.html"
  content_type = "text/html"
  content_encoding = "text/html"
}

# Create a CloudFlare DNS record
resource "cloudflare_record" "dev" {
  domain = "txmoose.com"
  name = "dev"
  value = "${aws_s3_bucket.dev-txmoose-com.website_endpoint}"
  type = "CNAME"
  depends_on = ["aws_s3_bucket.dev-txmoose-com"]
}
