resource "aws_ec2_transit_gateway" "tgw_a" {
  provider = aws.region_a

  description = "AWS TRANSIT GATEWAY A"

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "TGW-A"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "hub_attachment" {
  provider = aws.region_a

  transit_gateway_id = aws_ec2_transit_gateway.tgw_a.id
  vpc_id             = aws_vpc.hub.id

  subnet_ids = [
    aws_subnet.hub_tgw_subnet.id
  ]

  tags = {
    Name = "TGW-A-HUB-ATTACHMENT"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "prod_a_attachment" {
  provider = aws.region_a

  transit_gateway_id = aws_ec2_transit_gateway.tgw_a.id
  vpc_id             = aws_vpc.prod_a.id

  subnet_ids = [
    aws_subnet.prod_a_app.id
  ]

  tags = {
    Name = "TGW-A-PROD-A-ATTACHMENT"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "dev_a_attachment" {
  provider = aws.region_a

  transit_gateway_id = aws_ec2_transit_gateway.tgw_a.id
  vpc_id             = aws_vpc.dev_a.id

  subnet_ids = [
    aws_subnet.dev_a_app.id
  ]

  tags = {
    Name = "TGW-A-DEV-A-ATTACHMENT"
  }
}