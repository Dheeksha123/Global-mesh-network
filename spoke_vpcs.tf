# ---------- PROD SPOKE (Region A) ----------

resource "aws_vpc" "prod_a" {
  provider   = aws.region_a
  cidr_block = var.prod_a_cidr

  tags = {
    Name = "SPOKE-VPC-PROD-A"
  }
}

resource "aws_subnet" "prod_a_app" {
  provider          = aws.region_a
  vpc_id            = aws_vpc.prod_a.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "${var.region_a}a"

  tags = {
    Name = "prod-a-app-subnet"
  }
}

resource "aws_internet_gateway" "prod_a_igw" {
  provider = aws.region_a
  vpc_id   = aws_vpc.prod_a.id

  tags = {
    Name = "prod-a-igw"
  }
}

resource "aws_route_table" "prod_a_rt" {
  provider = aws.region_a
  vpc_id   = aws_vpc.prod_a.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_a_igw.id
  }

  tags = {
    Name = "prod-a-rt"
  }
}

resource "aws_route_table_association" "prod_a_assoc" {
  provider       = aws.region_a
  subnet_id      = aws_subnet.prod_a_app.id
  route_table_id = aws_route_table.prod_a_rt.id
}


# ---------- DEV SPOKE (Region A) ----------

resource "aws_vpc" "dev_a" {
  provider   = aws.region_a
  cidr_block = var.dev_a_cidr

  tags = {
    Name = "SPOKE-VPC-DEV-A"
  }
}

resource "aws_subnet" "dev_a_app" {
  provider          = aws.region_a
  vpc_id            = aws_vpc.dev_a.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "${var.region_a}a"

  tags = {
    Name = "dev-a-app-subnet"
  }
}

resource "aws_internet_gateway" "dev_a_igw" {
  provider = aws.region_a
  vpc_id   = aws_vpc.dev_a.id

  tags = {
    Name = "dev-a-igw"
  }
}

resource "aws_route_table" "dev_a_rt" {
  provider = aws.region_a
  vpc_id   = aws_vpc.dev_a.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_a_igw.id
  }

  tags = {
    Name = "dev-a-rt"
  }
}

resource "aws_route_table_association" "dev_a_assoc" {
  provider       = aws.region_a
  subnet_id      = aws_subnet.dev_a_app.id
  route_table_id = aws_route_table.dev_a_rt.id
}