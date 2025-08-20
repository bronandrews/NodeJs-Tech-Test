terraform {
  backend "s3" {
    key    = "VPC/Main/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region  = "eu-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.profile}-VPC"
  }
}

resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.networks_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.profile}-public-subnet1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.networks_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.profile}-public-subnet2"
  }
}

resource "aws_internet_gateway" "internet" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.profile}-igw"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet.id
  }

  tags = {
    Name = "${var.profile}-route"
  }
}

resource "aws_route_table_association" "route_assoc1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.route.id
}
resource "aws_route_table_association" "route_assoc2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.route.id
}
