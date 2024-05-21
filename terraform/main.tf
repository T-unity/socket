provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "web_server" {
  ami           = "ami-02a405b3302affc24"
  instance_type = "t3.micro"

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "WebSocketServer"
  }

  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  associate_public_ip_address = false
}

resource "aws_security_group" "web_server_sg" {
  name_prefix = "web_server_sg_"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "web_server_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "web_server_eip_assoc" {
  instance_id   = aws_instance.web_server.id
  allocation_id = aws_eip.web_server_eip.id
}

data "aws_route53_zone" "existing_zone" {
  zone_id = var.host_zone_id
}

resource "aws_route53_record" "socket_record" {
  zone_id = data.aws_route53_zone.existing_zone.zone_id
  name    = "socket.gynga.org"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.web_server_eip.public_ip]
}