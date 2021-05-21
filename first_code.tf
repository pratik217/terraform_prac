provider "aws" {
    profile = "default"
    region= "us-west-2"
}


resource "aws_s3_bucket" "tf_prac"{
    bucket = "tfprac21052021"
    acl    = "private"
}