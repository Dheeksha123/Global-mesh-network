resource "aws_ec2_transit_gateway_route_table" "spoke_rt" {
  provider = aws.region_a

  transit_gateway_id = aws_ec2_transit_gateway.tgw_a.id

  tags = {
    Name = "TGW-A-SPOKE-RT"
  }
}

resource "aws_ec2_transit_gateway_route_table" "hub_rt" {
  provider = aws.region_a

  transit_gateway_id = aws_ec2_transit_gateway.tgw_a.id

  tags = {
    Name = "TGW-A-HUB-RT"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "prod_a_spoke" {
  provider = aws.region_a

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "dev_a_spoke" {
  provider = aws.region_a

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "hub" {
  provider = aws.region_a

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub_rt.id
}

resource "aws_ec2_transit_gateway_route" "spoke_to_dev" {
  provider = aws.region_a

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
  destination_cidr_block         = var.dev_a_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub_attach.id
}

resource "aws_ec2_transit_gateway_route" "spoke_to_prod" {
  provider = aws.region_a

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
  destination_cidr_block         = var.prod_a_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub_attach.id
}

resource "aws_ec2_transit_gateway_route" "hub_to_prod" {
  provider = aws.region_a

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub_rt.id
  destination_cidr_block         = var.prod_a_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod_attach.id
}

resource "aws_ec2_transit_gateway_route" "hub_to_dev" {
  provider = aws.region_a

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub_rt.id
  destination_cidr_block         = var.dev_a_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_attach.id
}