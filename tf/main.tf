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
        Name = "georgep-challenge-route-public"
    }
}

resource "aws_route_table_association" "georgep-challenge-route-public" {
    subnet_id = "${aws_subnet.georgep-challenge-subnet-public.id}"
    route_table_id = "${aws_route_table.georgep-challenge-route-public.id}"
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

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
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
  key_name = "georgep-challenge-ssh-key"
  associate_public_ip_address = true
}

output "bastion" {
  value = "${aws_instance.georgep-challenge-ec2-bastion.public_ip}"
}

# Private Network, Host, etc.

# subnet private
resource "aws_subnet" "georgep-challenge-subnet-private" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${var.private_subnet_cidr}"

  tags {
    Name = "georgep-challenge-subnet-private"
  }
}

# Allow SSH from bastion host sg only
resource "aws_security_group" "georgep-challenge-sg-private" {
  name = "georgep-challenge-sg-private"

  tags {
    Name = "georgep-challenge-sg-private"
  }


  # Allow ICMP ping
  ingress {
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from bastion sg only
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
  }
  vpc_id = "${aws_vpc.vpc.id}"

}
# ec2 Private server
resource "aws_instance" "georgep-challenge-ec2-private" {
  ami = "${var.ami}"
  instance_type = "t2.micro"

  tags {
    Name = "georgep-challenge-ec2-private"
  }

  security_groups = ["${aws_security_group.georgep-challenge-sg-private.id}"]
  subnet_id = "${aws_subnet.georgep-challenge-subnet-private.id}"
  key_name = "georgep-challenge-ssh-key"
}

output "private" {
  value = "${aws_instance.georgep-challenge-ec2-private.private_ip}"
}

resource "aws_nat_gateway" "georgep-challenge-nat" {
  allocation_id = "${aws_eip.georgep-challenge-eip.id}"
  subnet_id     = "${aws_subnet.georgep-challenge-subnet-public.id}"

  tags {
    Name = "georgep-challenge-nat"
  }

  depends_on = ["aws_internet_gateway.georgep-challenge-igw"]
}

resource "aws_eip" "georgep-challenge-eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.georgep-challenge-igw"]
}

resource "aws_route_table" "georgep-challenge-route-private" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.georgep-challenge-nat.id}"
    }

    tags {
        Name = "georgep-challenge-route-private"
    }
}

resource "aws_route_table_association" "georgep-challenge-route-private" {
    subnet_id = "${aws_subnet.georgep-challenge-subnet-private.id}"
    route_table_id = "${aws_route_table.georgep-challenge-route-private.id}"
}

resource "aws_key_pair" "georgep-challenge-ssh-key" {
  key_name   = "georgep-challenge-ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDvvvqxuLT5d3ixFf8bbH280Bx9J3MsmpkxvmjUt2bm3rPcGQvJwHzAQUpTFuFQ3f5pqmSYUM4gF+8gRvNiK0pKvetE7o51dA0x0HxmHcoBXbZP5kKKNT6A+jUPreq6JNuoj+EgBceAWPzZaEQHYZ5kBHVLhZP4DHK5e4m9pxcT4LEXobGXm5TlhoOV9GyfV7g0J24SFg1bKbn1g5FcgGDObigDuyoHYxAjngS7tO3rk88MkGkJwM/jwC4w6+zpMmJ1uSoGDTvGSHwpp+0THZtDf3yypOrcBDvPbeCEr+sQIj72f9DWDvFkEZ+4by/cMvyGaiGhJ3PwWa3oifmMaWd4pq3aUkkUWhdIXjKzO+K2V50H7dtsL527CRDOmG8zWT3mRi2ELv3cU6TZ8PsyuywZXCopnPo4fCiCX8K0DKSgXSEAcpqEWUKQWwOjbd9AFekLvBdtwJrPZgjF1QMuj1NbKPpnqaVMc9eEyFTd6TzAIs/DjiRs+adwXKQWEdYjaXCq4CrqEiBfPHwsWlvIGU52lZEg2psU/vjbPqRkARVuAmdT20Xbn2W1BhIF1F85uVD/VzS47fGhI2HdrZYllw2j7z/Rdgnf9LcvGrzfZoPyXX7p+UvEAYL7MHO1t5/Gy2xOCNY0WPxB/2Ttz+XkQaxtBaOKEyTc3zbuA1C0NqDBmw== georgep@slalom.com"
}
