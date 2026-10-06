# =========================================================
# SPOKE TGW ROUTE TABLE
# =========================================================

resource "aws_ec2_transit_gateway_route_table" "spoke_rt" {
  provider = aws.region_a

  transit_gateway_id = aws_ec2_transit_gateway.tgw_a.id

  tags = {
    Name = "spoke-rt"
  }
}


# =========================================================
# HUB TGW ROUTE TABLE
# =========================================================

resource "aws_ec2_transit_gateway_route_table" "hub_rt" {
  provider = aws.region_a

  transit_gateway_id = aws_ec2_transit_gateway.tgw_a.id

  tags = {
    Name = "hub-rt"
  }
}


# =========================================================
# ATTACHMENT ASSOCIATIONS
# =========================================================

resource "aws_ec2_transit_gateway_route_table_association" "prod_assoc" {
  provider = aws.region_a

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.prod_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}


resource "aws_ec2_transit_gateway_route_table_association" "dev_assoc" {
  provider = aws.region_a

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.dev_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}


resource "aws_ec2_transit_gateway_route_table_association" "hub_assoc" {
  provider = aws.region_a

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.hub_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub_rt.id
}


# =========================================================
# SPOKE ROUTES → HUB
# =========================================================

resource "aws_ec2_transit_gateway_route" "spoke_to_hub_for_dev" {
  provider = aws.region_a

  destination_cidr_block = var.dev_a_cidr

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.hub_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}


resource "aws_ec2_transit_gateway_route" "spoke_to_hub_for_prod" {
  provider = aws.region_a

  destination_cidr_block = var.prod_a_cidr

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.hub_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}


# =========================================================
# HUB ROUTES → SPOKES
# =========================================================

resource "aws_ec2_transit_gateway_route" "hub_to_prod" {
  provider = aws.region_a

  destination_cidr_block = var.prod_a_cidr

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.prod_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub_rt.id
}


resource "aws_ec2_transit_gateway_route" "hub_to_dev" {
  provider = aws.region_a

  destination_cidr_block = var.dev_a_cidr

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.dev_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub_rt.id
}