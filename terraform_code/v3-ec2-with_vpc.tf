provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo-server" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name      = "splender"
  //security_groups = [ "demo-sg" ]
  vpc_security_group_ids = [ aws_security_group.demo-sg.id ]
  subnet_id = aws_subnet.code-public-subnet-01.id
  
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.code-vpc.id
  

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-port"
  }
}

resource "aws_vpc" "code-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "code-vpc"
  }
}

resource "aws_subnet" "code-public-subnet-01" {
  vpc_id = aws_vpc.code-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "code-public-subnet-01"
  }
}

resource "aws_subnet" "code-public-subnet-02" {
  vpc_id = aws_vpc.code-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    Name = "code-public-subnet-02"
  }
}

resource "aws_internet_gateway" "code-igw" {
  vpc_id = aws_vpc.code-vpc.id
  tags = {
    Name = "code-igw"
  }
}

resource "aws_route_table" "code-public-rt" {
  vpc_id = aws_vpc.code-vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.code-igw.id
  }
}

resource "aws_route_table_association" "code-rta-public-subnet-01" {
subnet_id = aws_subnet.code-public-subnet-01.id
route_table_id = aws_route_table.code-public-rt.id
}

resource "aws_route_table_association" "code-rta-public-subnet-02" {
subnet_id = aws_subnet.code-public-subnet-02.id
route_table_id = aws_route_table.code-public-rt.id
}