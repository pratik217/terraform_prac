provider "aws" {
    profile = "default"
    region= "us-west-2"
}


resource "aws_s3_bucket" "prodtf_prac"{
    bucket = "tf-prod-prac21052021"
    acl    = "private"
}

resource "aws_default_vpc" "default"{}

resource "aws_security_group" "prod-web"{
    name = "prod-web"
    description = "Allow http and https inbound and everything outbound"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port= 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
    tags = {
        "terraform" : "true"
    }    
}

resource "aws_instance" "prod_web" {
    ami = "ami-0715ec6d98dd151b5"
    instance_type= "t2.nano"

    vpc_security_group_ids=[
        aws_security_group.prod-web.id
    ]
    tags = {
        "terraform" : "true"
    }
}

resource "aws_eip" "prod_web"{
   instance= aws_instance.prod_web.id
   tags = {
        "terraform" : "true"
    } 
}
