provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = var.project_name
    }
  }
}

# WAF for CloudFront has to be created in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
