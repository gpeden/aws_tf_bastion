variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "instance_type" {
  default = "t2.medium"
}
variable "ami" {
  default = "ami-5e02b523"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.2.0/24"
}
