#create vpc
  module "eks-iam-roles" {
  source            = "../eks-iam-roles/"
  node_role_name    = "eks-node-group-nodes"
  cluster_role_name = "eks-cluster-demo"
}

/*
#0. Using external data to generate vpc time stamp
data "external" "vpc_name" {
  program = ["python", "${path.module}/name.py"]
}

*/
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "bootcampvpc"
    #Name = data.external.vpc_name.result.name
  }
}
#create igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw"
  }
}


#create eip
resource "aws_eip" "nat" {
  #domain   = "vpc"  # Use "vpc" for EIPs associated with a VPC
  #vpc   = true
  tags = {
    Name = "nat"
  }
}
# create natgw  
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "nat"
  }
}

/*
}
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

}
*/
# create public subnet
resource "aws_subnet" "public" {
  count                   = length(var.public_cidr)
  cidr_block              = element(var.public_cidr, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true




  tags = {
    Name                        = "public"
    "kubernetes.io/role/elb"    = "1"
    "kubernete.io/cluster/demo" = "owned"
  }
}
#create private subnet
resource "aws_subnet" "private" {
  count             = length(var.private_cidr)
  cidr_block        = element(var.private_cidr, count.index)
  availability_zone = element(var.availability_zone, count.index)
  vpc_id            = aws_vpc.main.id


  tags = {
    Name                        = "private"
    "kubernetes.io/role/elb"    = "1"
    "kubernete.io/cluster/demo" = "owned"

  }
}


#create private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  depends_on = [aws_subnet.private]
  tags = {
    Name = "private"
  }
}
# Create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  depends_on = [aws_subnet.public]
  tags = {
    Name = "public"
  }
}





#create public routes
resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_route_table.public]
  gateway_id             = aws_internet_gateway.igw.id
}
#create private routes
resource "aws_route" "private_natgw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id

  depends_on = [aws_route_table.private]
}
#private route associaton
resource "aws_route_table_association" "private" {
  count          = length(var.private_cidr)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id

  depends_on = [aws_route.private_natgw, aws_subnet.private]
}

#public route associaton
resource "aws_route_table_association" "public" {
  count          = length(var.public_cidr)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id

  depends_on = [aws_route.public_igw, aws_subnet.public]
}
