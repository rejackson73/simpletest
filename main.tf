provider "aws" {
  version = "~> 2.5"
  region  = var.region
  // access_key = data.vault_aws_access_credentials.creds.access_key
  // secret_key = data.vault_aws_access_credentials.creds.secret_key
  #security_token = data.vault_aws_access_credentials.creds.secret_key
}

// provider "vault" {
//   # It is strongly recommended to configure this provider through the
//   # environment variables described above, so that each user can have
//   # separate credentials set in the environment.
//   #
//   # This will default to using $VAULT_ADDR
//   # But can be set explicitly
//   # address = "https://vault.example.net:8200"
//   address = "http://192.168.1.218:8200"
// }


// data "vault_aws_access_credentials" "creds" {
//   backend = "aws2"
//   role    = "rjackson-vault"
//   type    = "sts"
//   ttl     = "15m"
// }


resource aws_vpc "nomad-demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    name = "${var.prefix}-vpc"
  }
}

resource aws_subnet "nomad-demo" {
  vpc_id     = aws_vpc.nomad-demo.id
  #vpc_id = "vpc-0ac388e345e4f2429"
  cidr_block = var.vpc_cidr
  tags = {
    name = "${var.prefix}-subnet"
  }
}

resource aws_security_group "nomad-demo" {
  name = "${var.prefix}-security-group"

  vpc_id = aws_vpc.nomad-demo.id
  #vpc_id = "vpc-0ac388e345e4f2429"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4648
    to_port     = 4648
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4647
    to_port     = 4647
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 4646
    to_port     = 4646
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
    from_port   = 8300
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
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

resource aws_internet_gateway "nomad-demo" {
  vpc_id = aws_vpc.nomad-demo.id
  #vpc_id = "vpc-0ac388e345e4f2429"

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

resource aws_route_table "nomad-demo" {
  vpc_id = aws_vpc.nomad-demo.id
  #vpc_id = "vpc-0ac388e345e4f2429"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nomad-demo.id
  }
}

resource aws_route_table_association "nomad-demo" {
  subnet_id      = aws_subnet.nomad-demo.id
  route_table_id = aws_route_table.nomad-demo.id
}


resource aws_instance "test-server" {
  ami                         = "ami-044120f0dd7ed0fb4"
  #ami                         = "ami-02b5ec5be3862a7ad"
  instance_type               = var.instance_type
  key_name                    = var.aws_key
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.nomad-demo.id
  vpc_security_group_ids      = [aws_security_group.nomad-demo.id]
  tags = {
    Name = "${var.prefix}-nomad-server-instance"
    Owner = var.owner_tag
  }
}
