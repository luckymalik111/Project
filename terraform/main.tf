terraform {
  required_version = ">= 1.0"

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

#############################
# S3 Bucket for Terraform State
#############################

resource "aws_s3_bucket" "terraform_state" {
  bucket = "lucky-terraform-state-bucket-123456"

  tags = {
    Name = "Terraform State Bucket"
  }
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

#############################
# DynamoDB Table for Locking
#############################

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

#############################
# Latest Amazon Linux 2023
#############################

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

#############################
# EC2 Instance
#############################

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

#############################
# Outputs
#############################

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

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table" {
  value = aws_dynamodb_table.terraform_locks.name
}
