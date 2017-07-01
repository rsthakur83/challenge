provider "aws" {
    region = "us-east-1"
}



resource "aws_launch_configuration" "machine-factory-v2" {
    name = "machine-factory-v2"
    image_id = "ami-b63769a1"
    security_groups = ["sg-68139219","sg-c51796b4"]
    instance_type = "t2.micro"
    key_name = "myappkeypair"
    user_data       = "${file("userdata.sh")}"
    lifecycle              { create_before_destroy = true }
}


resource "aws_autoscaling_group" "machine-factory-v2" {
  availability_zones = ["us-east-1b", "us-east-1c"]
  name = "machine-factory-v2"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  health_check_grace_period = 80
  health_check_type = "ELB"
  force_delete = false
  launch_configuration = "${aws_launch_configuration.machine-factory-v2.name}"
  load_balancers = ["web-elb"]
  vpc_zone_identifier = ["subnet-7e0d8952","subnet-c8473b80"]
}


output "Autoscaling group" {
  value = "${aws_autoscaling_group.machine-factory-v2.name}"
}
