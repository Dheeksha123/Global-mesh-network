resource "aws_security_group" "spoke_sg" {
  provider = aws.region_a
  name     = "spoke-test-sg"
  vpc_id   = aws_vpc.prod_a.id

  ingress {
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

resource "aws_security_group" "spoke_sg_dev" {
  provider = aws.region_a
  name     = "spoke-test-sg-dev"
  vpc_id   = aws_vpc.dev_a.id

  ingress {
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

resource "aws_instance" "prod_a_node" {
  provider                    = aws.region_a
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.prod_a_app.id
  vpc_security_group_ids      = [aws_security_group.spoke_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = true
  depends_on = [aws_route.prod_a_default_igw]

  user_data = "#!/bin/bash\ndnf install -y traceroute tcpdump"

timeouts {
    create = "5m"
  }

  tags = {
    Name = "prod-a-node"
  }
  
  
}




resource "aws_instance" "dev_a_node" {
  provider                    = aws.region_a
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.dev_a_app.id
  vpc_security_group_ids      = [aws_security_group.spoke_sg_dev.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = true
  depends_on = [aws_route.dev_a_default_igw]
  user_data = "#!/bin/bash\ndnf install -y traceroute tcpdump"

 timeouts {
    create = "5m"
  }
  tags = {
    Name = "dev-a-node"
  }
}

