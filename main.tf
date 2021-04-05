provider "aws" {
	region = "eu-west-3"
}

resource "aws_instance" "advocacy" {
	ami	="ami-0bb607148d8cf36fb"
	instance_type = "t2.micro"
	vpc_security_group_ids = ["${aws_security_group.instance.id}"]

	user_data = <<-EOF
		   #!/bin/bash
		   echo "Hello HashiCorp!" > index.html
		   nohup busybox httpd -f -p "${var.server_port}" &
		   EOF

	tags =  {
	   Name = "terraform-advocacy"
	}
}

resource "aws_launch_configuration" "advocacy" {
        image_id        ="ami-0bb607148d8cf36fb"
        instance_type   = "t2.micro"
        security_groups = ["${aws_security_group.instance.id}"]

        user_data = <<-EOF
                   #!/bin/bash
                   echo "Hello HashiCorp" > index.html
                   nohup busybox httpd -f -p "${var.server_port}" &
                   EOF

        lifecycle {
           create_before_destroy = true
        }
}

resource "aws_security_group" "instance" {
	name = "terraform-advocacy-instance"

	ingress {
		from_port   =  var.server_port
		to_port     =  var.server_port
		protocol    =  "tcp"
		cidr_blocks =  ["0.0.0.0/0"]
	}
	
	lifecycle {
           create_before_destroy = true
        }
}

data "aws_availability_zones" "all" {
}

