terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "lucky-terraform-state-bucket"
    key            = "ec2/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.46"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  key_name = "mumbai"

  subnet_id = "subnet-0de7c3f57addfa12c"

  vpc_security_group_ids = [
    "sg-0013983e757f1c30a"
  ]

  associate_public_ip_address = true

  tags = {
    Name        = "Terraform-EC2"
    Environment = "Dev"
  }
}

output "instance_id" {
  value = aws_instance.web_server.id
}

output "public_ip" {
  value = aws_instance.web_server.public_ip
}

output "private_ip" {
  value = aws_instance.web_server.private_ip
}

output "availability_zone" {
  value = aws_instance.web_server.availability_zone
}
