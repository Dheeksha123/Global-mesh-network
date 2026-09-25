resource "aws_vpc" "hub" {
  provider   = aws.region_a
  cidr_block = var.hub_cidr

  tags = {
    Name = "CENTRAL-SECURITY-HUB-VPC"
  }
}

resource "aws_subnet" "hub_tgw_subnet" {
  provider = aws.region_a

  vpc_id            = aws_vpc.hub.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region_a}a"

  tags = {
    Name = "hub-tgw-subnet"
  }
}

resource "aws_subnet" "hub_fw_subnet" {
  provider = aws.region_a

  vpc_id            = aws_vpc.hub.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region_a}a"

  map_public_ip_on_launch = true

  tags = {
    Name = "hub-fw-subnet"
  }
}

resource "aws_internet_gateway" "hub_igw" {
  provider = aws.region_a

  vpc_id = aws_vpc.hub.id

  tags = {
    Name = "hub-igw"
  }
}

resource "aws_route_table" "hub_fw_rt" {
  provider = aws.region_a

  vpc_id = aws_vpc.hub.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hub_igw.id
  }

  tags = {
    Name = "hub-fw-rt"
  }
}

resource "aws_route_table_association" "hub_fw_assoc" {
  provider = aws.region_a

  subnet_id      = aws_subnet.hub_fw_subnet.id
  route_table_id = aws_route_table.hub_fw_rt.id
}

resource "aws_route_table" "hub_tgw_rt" {
  provider = aws.region_a

  vpc_id = aws_vpc.hub.id

  tags = {
    Name = "hub-tgw-rt"
  }
}

resource "aws_route_table_association" "hub_tgw_assoc" {
  provider = aws.region_a

  subnet_id      = aws_subnet.hub_tgw_subnet.id
  route_table_id = aws_route_table.hub_tgw_rt.id
}