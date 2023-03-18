# Define the VPC

resource "aws_vpc" "FS_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    Name = "vpc_FS"
  }
}

# Define the public subnet

resource "aws_subnet" "FS_subnet" {
  vpc_id     = aws_vpc.FS_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"


  tags = {
    Name = "publicone"
  }
}

# Define a second public subnet in a different AZ

resource "aws_subnet" "FS_subnet_2" {
  vpc_id     = aws_vpc.FS_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"


  tags = {
    Name = "publictwo"
  }
}

# Define the internet gateway

resource "aws_internet_gateway" "FS_gateway" {
  vpc_id = aws_vpc.FS_vpc.id
}

# Define the route table

resource "aws_route_table" "FS_route_table" {
  vpc_id = aws_vpc.FS_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.FS_gateway.id
  }

   tags = {
    Name = "FS-route-table"
  }
}

# Associate the public subnet with the route table

resource "aws_route_table_association" "FS_association" {
  subnet_id      = aws_subnet.FS_subnet.id
  route_table_id = aws_route_table.FS_route_table.id
}

# Associate the second public subnet with the route table

resource "aws_route_table_association" "FS_association_2" {
  subnet_id      = aws_subnet.FS_subnet_2.id
  route_table_id = aws_route_table.FS_route_table.id
}

