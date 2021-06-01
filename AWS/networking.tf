###===== Creation of VPC =====###
resource "aws_vpc" "Custom" {
    cidr_block = "10.0.0.0/20"
    enable_dns_hostnames = true
    tags = {
      "Name" = "CustomVpc"
    }
  
}

//###===== Creation of Public subnet =====###
resource "aws_subnet" "Public" {
   vpc_id = aws_vpc.Custom.id
   cidr_block = "10.0.1.0/24"
   map_public_ip_on_launch = true
   tags = {
     "Name" = "Public subnet"
   }
  
}

//###===== Creation of Private subnet =====###
resource "aws_subnet" "Private" {
  vpc_id = aws_vpc.Custom.id
  cidr_block = "10.0.2.0/24"
  tags = {
    "Name" = "Private subnet"
  }
  
}

//###===== Creation of Internet gateway =====###
resource "aws_internet_gateway" "NewGW" {
  vpc_id = aws_vpc.Custom.id
  tags = {
    "Name" = "Public facing internet gateway"
  }
  
}
