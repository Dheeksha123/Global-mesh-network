data "aws_ami" "al2023" {
  provider    = aws.region_a
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-x86_64"]
  }
}

resource "aws_iam_role" "ssm_role" {
  provider = aws.region_a
  name     = "mesh-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  provider   = aws.region_a
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  provider = aws.region_a
  name     = "mesh-ssm-profile"
  role     = aws_iam_role.ssm_role.name
}

resource "aws_security_group" "firewall_sg" {
  provider    = aws.region_a
  name        = "firewall-sg"
  vpc_id      = aws_vpc.hub.id
  description = "Allow inspection traffic from spokes"

  ingress {
    description = "ICMP from Region A CIDR space"

    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "firewall" {
  provider      = aws.region_a
  ami           = data.aws_ami.al2023.id
  instance_type = "t2.micro"
  depends_on = [aws_route.hub_fw_default_igw]
  subnet_id = aws_subnet.hub_fw_subnet.id

  vpc_security_group_ids = [
    aws_security_group.firewall_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  source_dest_check = false

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    sysctl -w net.ipv4.ip_forward=1
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    dnf install -y tcpdump
  EOF

  tags = {
    Name = "central-firewall"
  }
}

resource "aws_route" "tgw_subnet_to_fw_for_prod" {
  provider = aws.region_a

  route_table_id = aws_route_table.hub_tgw_rt.id

  destination_cidr_block = var.prod_a_cidr

  network_interface_id = aws_instance.firewall.primary_network_interface_id
}

resource "aws_route" "tgw_subnet_to_fw_for_dev" {
  provider = aws.region_a

  route_table_id = aws_route_table.hub_tgw_rt.id

  destination_cidr_block = var.dev_a_cidr

  network_interface_id = aws_instance.firewall.primary_network_interface_id
}

resource "aws_route" "fw_subnet_to_tgw_for_prod" {
  provider = aws.region_a

  route_table_id = aws_route_table.hub_fw_rt.id

  destination_cidr_block = var.prod_a_cidr

  transit_gateway_id = aws_ec2_transit_gateway.tgw_a.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.hub_attach
  ]
}

resource "aws_route" "fw_subnet_to_tgw_for_dev" {
  provider = aws.region_a

  route_table_id = aws_route_table.hub_fw_rt.id

  destination_cidr_block = var.dev_a_cidr

  transit_gateway_id = aws_ec2_transit_gateway.tgw_a.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.hub_attach
  ]
}

resource "aws_route" "hub_fw_default_igw" {
  provider                = aws.region_a
  route_table_id           = aws_route_table.hub_fw_rt.id
  destination_cidr_block   = "0.0.0.0/0"
  gateway_id               = aws_internet_gateway.hub_igw.id
}