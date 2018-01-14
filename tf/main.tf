provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

# vpc
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"

  tags {
    Name = "georgep-challenge-vpc"
  }
}

resource "aws_internet_gateway" "georgep-challenge-igw" {
  vpc_id     = "${aws_vpc.vpc.id}"

  tags {
    Name = "georgep-challenge-igw"
  }
}

# subnet public
resource "aws_subnet" "georgep-challenge-subnet-public" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${var.public_subnet_cidr}"

  tags {
    Name = "georgep-challenge-subnet-public"
  }
}

resource "aws_route_table" "georgep-challenge-route-public" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.georgep-challenge-igw.id}"
    }

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_route_table_association" "georgep-challenge--route-public" {
    subnet_id = "${aws_subnet.georgep-challenge-subnet-public.id}"
    route_table_id = "${aws_route_table.georgep-challenge-route-public.id}"
}

# subnet private
resource "aws_subnet" "georgep-challenge-subnet-private" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${var.private_subnet_cidr}"

  tags {
    Name = "georgep-challenge-subnet-private"
  }
}

# security group public
resource "aws_security_group" "georgep-challenge-sg-bastion" {
  name = "georgep-challenge-sg-bastion"

  tags {
    Name = "georgep-challenge-sg-bastion"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.vpc.id}"

}

# ec2 bastion host
resource "aws_instance" "georgep-challenge-ec2-bastion" {
  ami = "${var.ami}"
  instance_type = "t2.micro"

  tags {
    Name = "georgep-challenge-ec2-bastion"
  }

  security_groups = ["${aws_security_group.georgep-challenge-sg-bastion.id}"]
  subnet_id = "${aws_subnet.georgep-challenge-subnet-public.id}"
  key_name = "georgep-challenge-key"
  associate_public_ip_address = true
}

output "bastion" {
  value = "${aws_instance.georgep-challenge-ec2-bastion.public_ip}"
}
