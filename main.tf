terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.5"
    }
  }
}
provider "aws" {
  region  = var.aws_region
  // access_key = data.vault_aws_access_credentials.creds.access_key
  // secret_key = data.vault_aws_access_credentials.creds.secret_key
}

data "aws_ami" "an_image" {
  most_recent      = true
  owners           = ["self"]
  filter {
    name   = "name"
    values = ["${var.owner_tag}-consul-*"]
  }
}

provider "vault" {
   address = "http://18.219.37.179:8200"
}


data "vault_aws_access_credentials" "creds" {
  backend = "aws"
  role    = "deity"
  ttl     = "15m"
}


resource aws_vpc "simple-demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    name = "${var.prefix}-vpc"
  }
}

resource aws_subnet "simple-demo" {
  vpc_id     = aws_vpc.simple-demo.id
  cidr_block = var.vpc_cidr
  tags = {
    name = "${var.prefix}-subnet"
  }
}

resource aws_security_group "simple-demo" {
  name = "${var.prefix}-security-group"

  vpc_id = aws_vpc.simple-demo.id
  #vpc_id = "vpc-0ac388e345e4f2429"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.prefix}-security-group"
  }
}

resource aws_internet_gateway "simple-demo" {
  vpc_id = aws_vpc.simple-demo.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

resource aws_route_table "simple-demo" {
  vpc_id = aws_vpc.simple-demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.simple-demo.id
  }
}

resource aws_route_table_association "simple-demo" {
  subnet_id      = aws_subnet.simple-demo.id
  route_table_id = aws_route_table.simple-demo.id
}

resource aws_instance "test-server" {
  count                       = 1
  ami                         = data.aws_ami.an_image.id
  instance_type               = var.instance_type
  key_name                    = var.aws_key
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.simple-demo.id
  vpc_security_group_ids      = [aws_security_group.simple-demo.id]
  tags = {
    Name = "${var.prefix}-simple-server-instance"
    Owner = var.owner_tag
  }
}
