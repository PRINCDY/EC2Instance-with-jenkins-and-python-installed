# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "~> 1.1.6"
#     }
#   }
# }

required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 1.1.6"
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAUMD25XDLCXESO2YP"
  secret_key = "zdZ6bCtqOQd7c6wVpjt8Q4FLLrtjMM8FiiKB1xpY"
  token      = "FwoGZXIvYXdzEF8aDOLt2ZRXMKponc8ntiK7AdI2F+7clxJVptXN8K0U7q6gLI1VuR2mbRMA55+YGbQEnP7V7O9lHFkfVnVaJdXMLcPvOyg790doBTkwCxgiDKpEAVHF0EL4ypiKGbqQfTnzqScl4pyhJtecGLzhWgqLxuZyUKKpy6g9dXcHDeyl+PhF7nnocqjDzYa6TgYE02ZkzBTsBEq96UWWBqfDGqcLYVPfYQVF4Ph85N/ik6qYQFzctA1cStMAX1y8AhdLNkAH4FmczrySJswb2Goo367vpQYyLVfrakKO1ra6R7NR548qcfTKPUr9ruFKFnx5OlB7tI+VvY+GODUqArPbbkpfzQ=="
}

variable "ingress-rules" {
  type    = list(number)
  default = [22, 8080]
}

dynamic "ingress" {
  iterator = port
  for_each = var.ingress-rules
  content {
    from_port   = port.value
    to_port     = port.value
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
  description = "SSH/Jenkins inbound, everything outbound"
}

resource "aws_instance" "ec2_v1" {
  ami   = "053b0d53c279acc90"
  count = "1"
  #   subnet_id = ""
  instance_type          = "t2.micro"
  key_name               = "key-pair"
  vpc_security_group_ids = [aws_security_group.web_traffic.id]
}

provisioner "remote-exec" {
  inline = [
    "sudo apt update && upgrade",
    "sudo apt install -y python3.8",
    "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
    "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ >/etc/apt/sources.list.d/jenkins.list'",
    "sudo apt-get update",
    "sudo apt-get install -y openjdk-8-jre",
    "sudo apt-get install -y jenkins",
  ]
}

connection {
  type        = "ssh"
  user        = "ubuntu"
  private_key = file("${path.module}/Key-pair.pem")
  host        = self.public_ip
}