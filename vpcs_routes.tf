resource "aws_route" "prod_a_to_dev_a" {
  provider               = aws.region_a
  route_table_id         = aws_route_table.prod_a_rt.id
  destination_cidr_block = var.dev_a_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_a.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.prod_attach
  ]
}

resource "aws_route" "dev_a_to_prod_a" {
  provider               = aws.region_a
  route_table_id         = aws_route_table.dev_a_rt.id
  destination_cidr_block = var.prod_a_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_a.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.dev_attach
  ]
}