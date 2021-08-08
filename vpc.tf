#vpc
resource "aws_vpc" "dev" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames=true
  enable_dns_support=true

  tags = {
    Name = "main_terraform_vpc"
  }
}

#public subnet
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.pub_subnetcidr1
  availability_zone = var.publicsubnet1_az
  map_public_ip_on_launch = true

  tags = {
    Name = "Main-terraform"
  }
  depends_on = [aws_vpc.dev]
}

#public subnet 2
resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.pub_subnetcidr2
  availability_zone = var.publicsubnet2_az
  map_public_ip_on_launch = true

  tags = {
    Name = "Main-terraform"
  }
  depends_on = [aws_vpc.dev]
}

#Private Subnet
resource "aws_subnet" "dev_pvt" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.pvt_subnetcidr
  availability_zone = var.pvtsubnet1_az
  map_public_ip_on_launch = false

  tags = {
    Name = "Main"
  }
  depends_on = [aws_vpc.dev]
}

#igw
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "dev-igw"
  }
}

#eip
resource "aws_eip" "nat_gateway" {
  vpc = true
}

#natGateway
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "gw NAT"
  }
   # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

#route table pub
resource "aws_route_table" "pubrt"{
  vpc_id = aws_vpc.dev.id
  route{
    cidr_block= "0.0.0.0/0"
    gateway_id= aws_internet_gateway.gw.id
  
  }

}

#Public route table association

resource "aws_route_table_association" "pub" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_route_table_association" "alb" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.pubrt.id
}

#Private route table
resource "aws_route_table" "pvtrt"{
  vpc_id = aws_vpc.dev.id
  route{
    cidr_block= "0.0.0.0/0"
    gateway_id= aws_nat_gateway.example.id

  }

}

#Private routetable association
resource "aws_route_table_association" "pvt"{
  subnet_id = aws_subnet.dev_pvt.id
  route_table_id = aws_route_table.pvtrt.id
}