provider "aws" {
    profile = "default"
    region= "us-west-2"
}


resource "aws_s3_bucket" "prodtf_prac"{
    bucket = "tf-prod-prac21052021"
    acl    = "private"
}

resource "aws_default_vpc" "default"{}