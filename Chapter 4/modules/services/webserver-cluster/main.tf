## EC2에 주석친 이유는 Auto Scaling으로 인스턴스를 생성했기 때문에 (주석 풀면 output도 풀기)
# resource "aws_instance" "example" {
#     ami = "ami-40d28157"
#     instance_type = "t2.micro"
#     vpc_security_group_ids = [ aws_security_group.instance.id ]

#     user_data = <<-EOF
#                 #!/bin/bash
#                 echo "Hello, World" > index.html
#                 nohup busybox httpd -f -p "${var.server_port}" &
#                 EOF

#     tags = {
#         Name = "terraform-example"
#     }
# }

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# 기존 az 전부 가져오기
data "aws_availability_zones" "all" {}

resource "aws_security_group" "elb"{
    name = "terraform-example-elb"

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 80
      protocol = "tcp"
      to_port = 80
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_launch_configuration" "example" {
    image_id = "ami-40d28157"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instance.id]

    user_data = data.template_file.user_data.rendered
    # <<-EOF
    #             #!/bin/bash
    #             echo "Hello, World" > index.html
    #             echo "${data.terraform_remote_state.db.address}" >> index.html
    #             echo "${data.terraform_remote_state.db.port}" >> index.html
    #             nohup busybox httpd -f -p "${var.server_port}" &
    #             EOF
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.id
    availability_zones = data.aws_availability_zones.all.names

    load_balancers = [aws_elb.example.name]
    health_check_type = "ELB"

    min_size = 2
    max_size = 10

    tag{
        key     = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }
  
}
resource "aws_elb" "example" {
  name = "terraform-asg-example"
  availability_zones = data.aws_availability_zones.all.names
  security_groups = [aws_security_group.elb.id]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = var.server_port
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout=3
    interval=30
    target = "HTTP:${var.server_port}/"
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "terraform-state-cloudest"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-1"
  }
}

data "template_file" "user_data"{
  template = file("user-data.sh")

  vars = {
    server_port  = var.server_port
    db_address   = data.terraform_remote_state.db.outputs.address
    db_port      = data.terraform_remote_state.db.outputs.port
  }
}