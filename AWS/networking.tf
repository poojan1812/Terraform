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
//###===== Creation of Routing table =====###
resource "aws_route_table" "NewRoute" {
  vpc_id = aws_vpc.Custom.id
  route = [ {
    cidr_block = "0.0.0.0/0"
    egress_only_gateway_id = "value"
    gateway_id = aws_internet_gateway.NewGW.id
    instance_id = "value"
    ipv6_cidr_block = "value"
    local_gateway_id = "value"
    nat_gateway_id = "value"
    network_interface_id = "value"
    transit_gateway_id = "value"
    vpc_endpoint_id = "value"
    vpc_peering_connection_id = "value"
  } ]
  tags = {
    "Name" = "Route table with internet gatewat"
  }
}

//###===== Association of routing table =====###
resource "aws_route_table_association" "PublicRoute" {
 route_table_id = aws_route_table.NewRoute.id
  subnet_id = aws_subnet.Public.id
}
