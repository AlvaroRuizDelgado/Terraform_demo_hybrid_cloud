provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "Example VPC"
  }
}

resource "aws_launch_configuration" "example" {
  image_id = "${var.centos7_ami}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.webserver_sg.id}"]

  user_data = <<-EOF
            #!/bin/bash
            echo "Hello! $HOSTNAME@AWS here." > index.html
            nohup busybox httpd -f -p "${var.server_port}" &
            EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "webserver_sg" {
  name = "terraform-webserver-sg"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "lb-sg" {
  name = "load-balancer-sg"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "example_asg" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]

  load_balancers = ["${aws_elb.example-lb.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tags {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_elb" "example-lb" {
  name = "Example-load-balancer"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]
  security_groups = ["${aws_security_group.lb-sg.id}"]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.server_port}/"
  }
}
