provider "aws" {
    profile = "default"
    region= "us-west-2"
}


resource "aws_s3_bucket" "prodtf_prac"{
    bucket = "tf-prod-prac21052021"
    acl    = "private"
}

resource "aws_default_vpc" "default"{}

resource "aws_default_subnet" "default_az1"{
    availability_zone = "us-west-2a"
    tags = {
        "terraform" : "true"
    }
}
resource "aws_default_subnet" "default_az2"{
    availability_zone = "us-west-2c"
    tags = {
        "terraform" : "true"
    }
}


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
    count =2

    ami = "ami-0715ec6d98dd151b5"
    instance_type= "t2.nano"

    vpc_security_group_ids=[
        aws_security_group.prod-web.id
    ]
    tags = {
        "terraform" : "true"
    }
}
resource "aws_eip_association" "prod_web"{
   instance_id= aws_instance.prod_web.0.id
    allocation_id =aws_eip.prod_web.id
}

resource "aws_eip" "prod_web"{
   
   tags = {
        "terraform" : "true"
    } 
}


resource "aws_elb" "prod_web" {
    name =  "prod-web"
    instances = aws_instance.prod_web.*.id
    subnets  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
    security_groups = [aws_security_group.prod-web.id]

    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
        
    }

    tags = {
        "terraform" : "true"
    } 
}

resource "aws_launch_template" "prod_web"{
    name_prefix ="prod-web"
    image_id = "ami"
    instance_type ="t2.nano"

}

resource "aws_autoscaling_group" "prod_web"{
    availability_zones= ["us-west-2b","us-west-2c"]
    vpc_zone_identifier =[aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
    desired_capacity =1
    max_size =1
    min_size=1
    launch_template {
        id =aws_launch_template.prod_web.id
        version ="$Latest"

    }
    tag{
        key = "terraform"
        value = "true"
        propagate_at_launch = true
    }



}


resource "aws_autoscaling_attachment" "prod_web" {
  autoscaling_group_name = aws_autoscaling_group.prod_web.id
  elb                    = aws_elb.prod_web.id
}


module "web_app" {
  source = "./modules/web_app"

  web_image_id         = var.web_image_id
  web_instance_type    = var.web_instance_type
  web_desired_capacity = var.web_desired_capacity
  web_max_size         = var.web_max_size
  web_min_size         = var.web_min_size
  subnets              = [aws_default_subnet.default_az1.id,aws_default_subnet.default_az2.id]
  security_groups      = [aws_security_group.prod_web.id]
  web_app	       = "prod"
}