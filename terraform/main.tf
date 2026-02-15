terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = "us-east-1" # You can change this
}

# 1. Create a Security Group to allow Jenkins (8080) and SSH (22)
resource "aws_security_group" "jenkins_sg" {
  name = "jenkins_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For learning only; in prod, use your IP
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

# 2. Create the EC2 Instance
resource "aws_instance" "devops_server" {
  ami                    = "ami-0030e4319cbf4dbf2" # Ubuntu 22.04 LTS (verify for your region)
  instance_type          = "t3.small"
  key_name               = "ansible-lab.pem" # Make sure this exists in AWS
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = { Name = "Jenkins-Master-Node" }
}

output "public_ip" {
  value = aws_instance.devops_server.public_ip
}
