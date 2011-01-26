
require 'ynetaddr'

describe Net::IPv6IfAddr, 'constructor' do
  it 'accepts hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh:hhhh/l format' do
    Net::IPv6IfAddr.new('2a02:20:1:2:3:4:5:6/64').addr.should == 0x2a020020000100020003000400050006
    Net::IPv6IfAddr.new('2a02:20:1:2:3:4:5:6/64').length.should == 64
  end

  it 'rejects network address' do
    lambda { Net::IPv6IfAddr.new('2a02:20::/64') }.should raise_error(ArgumentError)
  end

  it 'reject invalid empty address' do
    lambda { Net::IPv6IfAddr.new('') }.should raise_error(ArgumentError)
  end

  it 'reject addr without length' do
    lambda { Net::IPv6IfAddr.new('2a02:20::1') }.should raise_error(ArgumentError)
  end

  it 'reject addr with slash but without length' do
    lambda { Net::IPv6IfAddr.new('2a02:20::1/') }.should raise_error(ArgumentError)
  end

  it 'reject addr without addr' do
    lambda { Net::IPv6IfAddr.new('/64') }.should raise_error(ArgumentError)
  end
end

describe Net::IPv6IfAddr, :mask_hex do
  it 'is correctly calculated' do
    Net::IPv6IfAddr.new('::1/0').mask_hex.should == '0000:0000:0000:0000:0000:0000:0000:0000'
    Net::IPv6IfAddr.new('2a::1/8').mask_hex.should == 'ff00:0000:0000:0000:0000:0000:0000:0000'
    Net::IPv6IfAddr.new('2a02:20::1/32').mask_hex.should == 'ffff:ffff:0000:0000:0000:0000:0000:0000'
    Net::IPv6IfAddr.new('2a02:20::1/127').mask_hex.should == 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffe'
    Net::IPv6IfAddr.new('2a02:20::1/128').mask_hex.should == 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff'
  end
end

describe Net::IPv6IfAddr, :wildcard_hex do
  it 'is correctly calculated' do
    Net::IPv6IfAddr.new('::1/0').wildcard_hex.should == 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff'
    Net::IPv6IfAddr.new('2a::1/8').wildcard_hex.should == '00ff:ffff:ffff:ffff:ffff:ffff:ffff:ffff'
    Net::IPv6IfAddr.new('2a02:20::1/32').wildcard_hex.should == '0000:0000:ffff:ffff:ffff:ffff:ffff:ffff'
    Net::IPv6IfAddr.new('2a02:20::1/127').wildcard_hex.should == '0000:0000:0000:0000:0000:0000:0000:0001'
    Net::IPv6IfAddr.new('2a02:20::1/128').wildcard_hex.should == '0000:0000:0000:0000:0000:0000:0000:0000'
  end
end

# parent class methods

describe Net::IPv6IfAddr, :network do
  it 'is correctly calculated' do
    Net::IPv6IfAddr.new('::1/0').network.should == '::/0'
    Net::IPv6IfAddr.new('2a::1/8').network.should == '2a::/8'
    Net::IPv6IfAddr.new('2a02:20::1/32').network.should == '2a02:20::/32'
    Net::IPv6IfAddr.new('2a02:20:ffff:ffff:ffff:ffff:ffff:ffff/32').network.should == '2a02:20::/32'
    Net::IPv6IfAddr.new('2a02:20::1/127').network.should == '2a02:20::0/127'
    Net::IPv6IfAddr.new('2a02:20::1/128').network.should == '2a02:20::1/128'
  end
end

describe Net::IPv6IfAddr, :mask do
  it 'is correctly calculated' do
    Net::IPv6IfAddr.new('::1/0').mask.should == 0x00000000000000000000000000000000
    Net::IPv6IfAddr.new('2a::1/8').mask.should == 0xff000000000000000000000000000000
    Net::IPv6IfAddr.new('2a02:20::1/32').mask.should == 0xffffffff000000000000000000000000
    Net::IPv6IfAddr.new('2a02:20::1/127').mask.should == 0xfffffffffffffffffffffffffffffffe
    Net::IPv6IfAddr.new('2a02:20::1/128').mask.should == 0xffffffffffffffffffffffffffffffff
  end
end

describe Net::IPv6IfAddr, :wildcard do
  it 'is correctly calculated' do
    Net::IPv6IfAddr.new('::1/0').wildcard.should == 0xffffffffffffffffffffffffffffffff
    Net::IPv6IfAddr.new('2a::1/8').wildcard.should == 0x00ffffffffffffffffffffffffffffff
    Net::IPv6IfAddr.new('2a02:20::1/32').wildcard.should == 0x00000000ffffffffffffffffffffffff
    Net::IPv6IfAddr.new('2a02:20::1/127').wildcard.should == 0x00000000000000000000000000000001
    Net::IPv6IfAddr.new('2a02:20::1/128').wildcard.should == 0x00000000000000000000000000000000
  end
end


describe Net::IPv6IfAddr, :address do
  it 'is correctly calculated' do
    Net::IPv6IfAddr.new('::1/0').address.should == '::1'
    Net::IPv6IfAddr.new('2a::1/8').address.should == '2a::1'
    Net::IPv6IfAddr.new('2a02:20::1/32').address.should == '2a02:20::1'
    Net::IPv6IfAddr.new('2a02:20::1/127').address.should == '2a02:20::1'
    Net::IPv6IfAddr.new('2a02:20::1/128').address.should == '2a02:20::1'
  end
end

describe Net::IPv6IfAddr, :nic_id do
  it 'is correctly calculated' do
    Net::IPv6IfAddr.new('::1/0').nic_id.should == 1
    Net::IPv6IfAddr.new('2a::1/8').nic_id.should == 0x002a0000000000000000000000000001
    Net::IPv6IfAddr.new('2a02:20::1/32').nic_id.should == 1
    Net::IPv6IfAddr.new('2a02:20::1/127').nic_id.should == 1
    Net::IPv6IfAddr.new('2a02:20::1/128').nic_id.should == 0
  end
end

describe Net::IPv6IfAddr, :include? do
  it 'matches correctly' do
    (Net::IPv6IfAddr.new('2a02:20::1/32').include?('2a02:19::0')).should be_false
    (Net::IPv6IfAddr.new('2a02:20::1/32').include?('2a02:20::0')).should be_true
    (Net::IPv6IfAddr.new('2a02:20::1/32').include?('2a02:20::1')).should be_true
    (Net::IPv6IfAddr.new('2a02:20::1/32').include?('2a02:20:ffff::1')).should be_true
  end
end

describe Net::IPv6IfAddr, :== do
  it 'return true if interface addresses are equal' do
    (Net::IPv6IfAddr.new('2a02:20::1/32') == '2a02:20::1/32').should be_true
  end

  it 'returns false if interface addreses have different address' do
    (Net::IPv6IfAddr.new('2a02:20::2/32') == '2a02:20::1/32').should be_false
  end

  it 'returns false if interface addreses have different mask length' do
    (Net::IPv6IfAddr.new('2a02:20::1/32') == '2a02:20::1/31').should be_false
  end
end

describe Net::IPv6IfAddr, :to_s do
  it 'produces correct output' do
    Net::IPv6IfAddr.new('::1/0').to_s.should == '::1/0'
    Net::IPv6IfAddr.new('2a::1/8').to_s.should == '2a::1/8'
    Net::IPv6IfAddr.new('2a02:20::1/32').to_s.should == '2a02:20::1/32'
    Net::IPv6IfAddr.new('2a02:20::1/127').to_s.should == '2a02:20::1/127'
    Net::IPv6IfAddr.new('2a02:20::1/128').to_s.should == '2a02:20::1/128'
  end
end

describe Net::IPv6IfAddr, :to_hash do
  it 'is correctly calculated' do
    Net::IPv6IfAddr.new('::5/32').should == { :addr => 0x5, :length => 32 }
  end
end
