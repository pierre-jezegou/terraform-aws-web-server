provider "aws" {
  region        = var.region
}

data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow http and ssh traffic for instances"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Autoriser tout le trafic sortant
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Project"     = "ccbda bootstrap"
    "Cost-center" = "laboratory"
  }
}

resource "aws_security_group" "load_balancer_sg" {
  name        = "load-balancer-sg"
  description = "Allow HTTP and HTTPS for Load Balancer"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Autoriser tout le trafic sortant
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Project"     = "ccbda bootstrap"
    "Cost-center" = "laboratory"
  }
}

resource "aws_instance" "ec2_instance" {
  ami             = var.image_ami
  instance_type   = "t2.micro"
  key_name        = var.key_name
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #! /bin/bash -ex
              # This script is for Ubuntu
              sudo apt-get update
              sudo apt-get -y install apache2
              sudo systemctl enable apache2
              sudo systemctl start apache2
              sudo apt-get -y install mysql-client
              sudo apt-get -y install php8.1-mysql php8.1-curl php8.1-cgi php8.1 libapache2-mod-php8.1 php-xml php8.1-zip
              sudo usermod -a -G www-data ubuntu
              sudo chown -R root:www-data /var/www
              sudo chmod 2775 /var/www
              sudo find /var/www -type d -exec chmod 2775 {} +
              sudo find /var/www/ -type f -exec chmod 0664 {} +
              EOF

  tags = {
    "Project"     = "ccbda bootstrap"
    "Name"        = "apache-web-server"
    "Cost-center" = "laboratory"
  }
}

resource "aws_lb" "load_balancer" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [aws_security_group.load_balancer_sg.id]

  tags = {
    "Project"     = "ccbda bootstrap"
    "Cost-center" = "laboratory"
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "primary-apache-web-server-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id
}

data "aws_instances" "ec2_instances" {
  filter {
    name   = "tag:Name"
    values = ["apache-web-server"]
  }
}


resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}


resource "aws_lb_target_group_attachment" "ec2_target_attachments" {
  count            = length(data.aws_instances.ec2_instances.ids)
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = data.aws_instances.ec2_instances.ids[count.index]
}