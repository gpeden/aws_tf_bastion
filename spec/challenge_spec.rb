require './spec/spec_helper'

# vpc
describe vpc('georgep-challenge-vpc') do
  it { should exist }
  its(:cidr_block) { should eq '10.0.0.0/16' }
end

# bastion security Group

# private security group

# subnets

# internet gateway

# ec2 bastion

# ec2 private

# bastion to private route

# NAT gateway
