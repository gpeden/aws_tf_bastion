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

# subnet public

resource "aws_subnet" "subnet-public" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.1.0/24"

  tags {
    Name = "georgep-challenge-subnet-public"
  }
}

# subnet private

resource "aws_subnet" "subnet-private" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.2.0/24"

  tags {
    Name = "georgep-challenge-subnet-private"
  }
}
