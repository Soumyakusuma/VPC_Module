terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.98.0"
    }
  }


 
  backend "s3" {
    bucket = "devops-pract"
    key    = "vpc_test"
    region = "us-east-1"
    #dynamodb_table="vpc_test"
    encrypt=true
    use_lockfile=true
  }
}


provider "aws" {
  # Configuration options
  
}
