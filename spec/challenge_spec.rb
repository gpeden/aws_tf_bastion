require './spec/spec_helper'

# vpc
describe vpc('georgep-challenge-vpc') do
  it { should exist }
  its(:cidr_block) { should eq '10.0.0.0/16' }
end

# igw
describe internet_gateway('georgep-challenge-igw') do
  it { should exist }
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

describe route_table('georgep-challenge-route-public') do
  it { should exist }
  it { should have_route('0.0.0.0/0').target(gateway: 'georgep-challenge-igw') }
end

# bastion security Group
describe security_group('georgep-challenge-sg-bastion') do
  it { should exist }
  it { should have_tag('Name').value('georgep-challenge-sg-bastion') }
  its(:inbound) { should be_opened(22).protocol('tcp') }
  it { should belong_to_vpc('georgep-challenge-vpc') }
end

# ec2 bastion
# exercise ec2 instance
describe ec2('georgep-challenge-ec2-bastion') do
  it { should exist }
  it { should be_running }
  its(:image_id) { should eq 'ami-5e02b523' }
  its(:instance_type) { should eq 't2.micro' }
  it { should have_tag('Name').value('georgep-challenge-ec2-bastion') }
  it { should belong_to_vpc('georgep-challenge-vpc') }
  it { should have_security_group('georgep-challenge-sg-bastion') }
  it { should belong_to_subnet('georgep-challenge-subnet-public') }
end

# private ec2 instance
describe ec2('georgep-challenge-ec2-private') do
  it { should exist }
  it { should be_running }
  its(:image_id) { should eq 'ami-5e02b523' }
  its(:instance_type) { should eq 't2.micro' }
  it { should have_tag('Name').value('georgep-challenge-ec2-private') }
  it { should belong_to_vpc('georgep-challenge-vpc') }
  it { should have_security_group('georgep-challenge-sg-private') }
  it { should belong_to_subnet('georgep-challenge-subnet-private') }
end

# NAT gateway
describe nat_gateway('georgep-challenge-nat') do
  it { should exist }
end
