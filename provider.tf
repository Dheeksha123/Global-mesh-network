terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "region_a"
  region = var.region_a
}

provider "aws" {
  alias  = "region_b"
  region = var.region_b
}