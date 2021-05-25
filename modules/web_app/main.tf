resource "aws_elb" "this" {
    name =  "${var.web-app}-web"
    subnets  = var.subnets
    security_groups = var.security_groups

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

resource "aws_launch_template" "this"{
    name_prefix ="${var.web-app}-web"
    image_id = "ami"
    instance_type ="t2.nano"

}

resource "aws_autoscaling_group" "this"{
    availability_zones= ["us-west-2b","us-west-2c"]
    vpc_zone_identifier =var.subnets
    desired_capacity =1
    max_size =1
    min_size=1
    launch_template {
        id =aws_launch_template.this.id
        version ="$Latest"

    }
    tag{
        key = "terraform"
        value = "true"
        propagate_at_launch = true
    }



}


resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  elb                    = aws_elb.this.id
}