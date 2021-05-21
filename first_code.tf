provider "aws" {
    profile = "default"
    region= "us-west-2"
}


resource "aws_s3_bucket" "tf_prac"{
    bucket = "tf_prac_21052021"
    acl    = "private"
}