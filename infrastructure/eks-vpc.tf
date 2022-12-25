# This creates a VPC with:
# - 3 public subnets, including an internet gateway
# - 3 private subnets, including a NAT gateway
# Furthermore it creates the corresponding route tables and
# route table associations.

resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"
}

### PUBLIC SUBNETS and Internet Gateway ###
resource "aws_subnet" "eks_public_eu-west-1a" {
  vpc_id                  = aws_vpc.eks.id
  availability_zone       = "eu-west-1a"
  cidr_block              = "10.0.0.0/19"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "eks_public_eu-west-1b" {
  vpc_id                  = aws_vpc.eks.id
  availability_zone       = "eu-west-1b"
  cidr_block              = "10.32.0.0/19"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "eks_public_eu-west-1c" {
  vpc_id                  = aws_vpc.eks.id
  availability_zone       = "eu-west-1c"
  cidr_block              = "10.64.0.0/19"
  map_public_ip_on_launch = true
}
# Internet Gateway for public subnets
resource "aws_internet_gateway" "eks" {
  vpc_id = aws_vpc.eks.id
}
# Route Table for public subnets
resource "aws_route_table" "eks_public" {
  vpc_id = aws_vpc.eks.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks.id
  }
}
# Route Table Association for public subnets
resource "aws_route_table_association" "eks_public_eu-west-1a" {
  subnet_id      = aws_subnet.eks_public_eu-west-1a.id
  route_table_id = aws_route_table.eks_public.id
}
resource "aws_route_table_association" "eks_public_eu-west-1b" {
  subnet_id      = aws_subnet.eks_public_eu-west-1b.id
  route_table_id = aws_route_table.eks_public.id
}
resource "aws_route_table_association" "eks_public_eu-west-1c" {
  subnet_id      = aws_subnet.eks_public_eu-west-1c.id
  route_table_id = aws_route_table.eks_public.id
}

### PRIVATE SUBNETS and NAT Gateway ###
resource "aws_subnet" "eks_private_eu-west-1a" {
  vpc_id            = aws_vpc.eks.id
  availability_zone = "eu-west-1a"
  cidr_block        = "10.96.0.0/19"
}
resource "aws_subnet" "eks_private_eu-west-1b" {
  vpc_id            = aws_vpc.eks.id
  availability_zone = "eu-west-1b"
  cidr_block        = "10.128.0.0/19"
}
resource "aws_subnet" "eks_private_eu-west-1c" {
  vpc_id            = aws_vpc.eks.id
  availability_zone = "eu-west-1c"
  cidr_block        = "10.160.0.0/19"
}
# NAT gateway for private subnets
resource "aws_eip" "eks_eu-west-1a" {
  vpc = true
  # It is recommended to add an explicit dependency
  depends_on = [aws_internet_gateway.eks]
}
# for high availability, we would need to create a NAT gateway in each AZ
resource "aws_nat_gateway" "eks_eu-west-1a" {
  allocation_id = aws_eip.eks_eu-west-1a.id
  subnet_id     = aws_subnet.eks_private_eu-west-1a.id
  # It is recommended to add an explicit dependency
  depends_on = [aws_internet_gateway.eks]
}
# Route Table and associations for private subnets
# we create a route table for each AZ in case we add more NAT gateways
resource "aws_route_table" "eks_private_eu-west-1a" {
  vpc_id = aws_vpc.eks.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_eu-west-1a.id
  }
}
resource "aws_route_table" "eks_private_eu-west-1b" {
  vpc_id = aws_vpc.eks.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_eu-west-1a.id
  }
}
resource "aws_route_table" "eks_private_eu-west-1c" {
  vpc_id = aws_vpc.eks.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_eu-west-1a.id
  }
}
resource "aws_route_table_association" "eks_private_eu-west-1a" {
  subnet_id      = aws_subnet.eks_private_eu-west-1a.id
  route_table_id = aws_route_table.eks_private_eu-west-1a.id
}
resource "aws_route_table_association" "eks_private_eu-west-1b" {
  subnet_id      = aws_subnet.eks_private_eu-west-1b.id
  route_table_id = aws_route_table.eks_private_eu-west-1b.id
}
resource "aws_route_table_association" "eks_private_eu-west-1c" {
  subnet_id      = aws_subnet.eks_private_eu-west-1c.id
  route_table_id = aws_route_table.eks_private_eu-west-1c.id
}
