variable "secret_key" {}
variable "access_key" {}

# Configure aws with a default region
provider "aws" {
  secret_key = "${var.secret_key}"
  access_key = "${var.access_key}"
  region = "us-east-1"
}

# Create a demo s3 bucket
resource "aws_s3_bucket" "moosedev_tf_website" {
  bucket = "moosedev-tf-website"
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
  bucket = "${aws_s3_bucket.moosedev_tf_website.id}"
  key = "index.html"
  source = "./index.html"
  content_type = "text/html"
  content_encoding = "text/html"
}
