require './spec/spec_helper'

# vpc
describe vpc('georgep-challenge-vpc') do
  it { should exist }
  its(:cidr_block) { should eq '10.0.0.0/16' }
end

# subnets
describe subnet('georgep-challenge-subnet-public') do
  it { should exist }
  its(:cidr_block) { should eq '10.0.1.0/24' }
end

describe subnet('georgep-challenge-subnet-private') do
  it { should exist }
  its(:cidr_block) { should eq '10.0.2.0/24' }
end

# bastion security Group
describe security_group('georgep-challenge-sg-bastion') do
  it { should exist }
  it { should have_tag('Name').value('georgep-challenge-sg-bastion') }
  its(:inbound) { should be_opened(22).protocol('tcp') }
  it { should belong_to_vpc('georgep-challenge-vpc') }
end

# private security group

# subnets

# internet gateway

# ec2 bastion

# ec2 private

# bastion to private route

# NAT gateway
