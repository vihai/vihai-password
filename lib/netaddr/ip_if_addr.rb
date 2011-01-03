
module Netaddr

  class IPIfAddr

    # @return [IPNet] the network containing the interface address
    #
    def network
      @net_class.new(:prefix => @addr & mask, :length => @length)
    end

    # @return the mask as host byte-ordering Integer
    #
    def mask
      @fullmask ^ (@fullmask >> @length)
    end

    # @return [Integer] the wildcard (mask bitwise negation) in host byte-ordering
    #
    def wildcard
      @fullmask >> @length
    end

    # @return [IPAddr] containing the IP address
    #
    def address
      @addr
    end

    # @return [IPAddr] containing the host part (nic ID in IPv6 terms) of interface address
    #
    def nic_id
      @addr.to_i & (@fullmask >> @length)
    end

    # @return [Boolean] true if the specified IP address is included in the same interface's network
    #
    def include?(addr)
      network.include?(addr)
    end

    # @return [Boolean] true if both objects represent the same interface address
    #
    def ==(other)
      other = self.class.new(other) if !other.kind_of?(self.class)
      @addr == other.addr && @length == other.length
    end

    # @return [String] a string representation of the interface address in the form a.b.c.d/nn
    #
    def to_s
      "#{address.to_s}/#{@length}"
    end

    # @return [Hash] a Hash with :addr and :length keys respectively containing the Integer representation of interface's
    #                address and network mask length
    #
    def to_hash
      { :addr => @addr, :length => @length }
    end

    # @return [String] a human-readable representation of the object
    #
    def inspect
      "#<%#{self.class.to_s}:#{to_s}>"
    end

  end

end