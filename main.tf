#defining the key pair 
resource "aws_key_pair" "onos-keypair" {
  key_name   = "onos_keypair"
  public_key = file("~/.ssh/id_rsa.pub")
  tags = {
    Name = "onos-keypair"
  }
}

#creating the vpc
resource "aws_vpc" "onos-vpc" {
  cidr_block = var.onos-cidr

  tags = {
    Name = "onos-vpc"
  }
}

#creating internet gateway for the vpc
resource "aws_internet_gateway" "onos-internet-gateway" {
  vpc_id = aws_vpc.onos-vpc.id

  tags = {
    Name = "onos-internet-gateway"
  }
}

#creating the route table
resource "aws_route_table" "onos-route-table" {
  vpc_id = aws_vpc.onos-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.onos-internet-gateway.id
  }

  tags = {
    Name = "onos-route-table"
  }
}

#creating the subnet (public subnet)
resource "aws_subnet" "onos-subnet" {
  vpc_id            = aws_vpc.onos-vpc.id
  cidr_block        = var.onos-subnet-cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "onos-subnet"
  }
}

#associate subnet to route table
resource "aws_route_table_association" "onos-route-table-association" {
  subnet_id      = aws_subnet.onos-subnet.id
  route_table_id = aws_route_table.onos-route-table.id
}

#creating your security group
resource "aws_security_group" "onos-allow-web-traffic" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.onos-vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "onos-allow-web-traffic"
  }
}

#creating your network interface
resource "aws_network_interface" "onos-nic" {
  subnet_id       = aws_subnet.onos-subnet.id
  private_ips     = ["10.2.1.50"]
  security_groups = [aws_security_group.onos-allow-web-traffic.id]

}

#creating and assigning your elastic ip 
resource "aws_eip" "onos-test-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.onos-nic.id
  associate_with_private_ip = "10.2.1.50"
  depends_on                = [aws_internet_gateway.onos-internet-gateway]
}

#creating the the instance and launching your webserver
resource "aws_instance" "onos" {
  ami               = "ami-095889fa7a7b9da4e"
  instance_type     = "m6gd.medium"
  availability_zone = "us-east-1a"

  network_interface {
    network_interface_id = aws_network_interface.onos-nic.id
    device_index         = 0
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install apache2 -y
    sudo systemctl start apache2
    sudo bash -c 'echo you have installed and started your webserver > /var/www/html/index.html'
    EOF

  tags = {
    Name = "onos"
  }
}