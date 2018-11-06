##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

##################################################################################
# DATA
##################################################################################

data "aws_subnet" "public" {
  count = "${length(data.aws_subnet_ids.selected.ids)}"
  id = "${data.aws_subnet_ids.selected.ids[count.index]}"
}

data "aws_subnet_ids" "selected" {
  vpc_id = "${var.vpc_id}"
}

##################################################################################
# ALB CONFIG
##################################################################################
resource "aws_lb" "test" {
  name               = "${var.alb_name}-alb"
  internal           = false
  load_balancer_type = "application"
  
  subnets            = ["${data.aws_subnet.public.*.id}"]

  security_groups = ["${var.security_group_id}"]

  enable_deletion_protection = false

  tags {
    Name = "alb-${var.alb_name}"
  }
}

resource "aws_lb_target_group" "test" {
  name     = "alb-tg-${var.alb_name}"
  port     = 80
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"
  depends_on = ["aws_instance.web"]
}


resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.test.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.test.arn}"
    type             = "forward"
  }
}

##################################################################################
# DEPLOY INSTANCES
##################################################################################
resource "aws_instance" "web" {
  count         = "${var.num_vm}"
  ami           = "${var.ami_id}"
  instance_type = "t2.micro"
  subnet_id = "${element(data.aws_subnet_ids.selected.ids, count.index)}"
  vpc_security_group_ids = ["${var.security_group_id}"]
  key_name = "${var.key_name}"
  root_block_device {
    delete_on_termination = true
  }
  tags {
    Name = "mjolnir build Test"
  }

  provisioner "remote-exec" {
    inline =
     [
     # Creates the file that contains enviormental variables that'll be sourced by other scripts
       "touch envVar.sh",
     # Initializes the NUM_CONTAINERS variable in the file
       "echo \"NUM_CONTAINERS=${var.containers}\" > envVar.sh",
     # Moves the file to the correct directory to be sourced by other scripts
       "sudo mv envVar.sh /usr/bin/",
     ]
    connection
    {
      type = "ssh"
      user = "${var.username}"
      private_key = "${file("~/mjolnirKey.pem")}"
    }
  }
}

resource "null_resource" "update" {
  count = "${var.num_vm}"
  triggers = 
  {
    cluster_instance_ids = "${join(",", aws_instance.web.*.id)}",
    container_count = "${var.containers}"
  }

  connection
  {
    type = "ssh"
    user = "${var.username}"
    private_key = "${file("~/mjolnirKey.pem")}"
    host = "${element(aws_instance.web.*.public_ip, count.index)}"
    # host = "${aws_instance.web.*.public_ip}"

  }

  provisioner "remote-exec" {
      inline = [
        "sudo docker kill $(sudo docker ps -q)",
        "echo \"NUM_CONTAINERS=${var.containers}\" > envVar.sh",
        "sudo mv envVar.sh /usr/bin/",
        "sudo systemctl restart mjolnirWebService",

      ]
  }
}
##################################################################################
# INSTANCES
##################################################################################

