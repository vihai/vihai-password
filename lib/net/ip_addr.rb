
module Net

  class IPAddr

    # @param [String, IPv4Net] net An IPv4Net or String representation of an IPv4 network
    # @return [Boolean] true if the IPv4 network includes this IP address
    #
    def included_in?(net)
      net = @net_class.new(net) if !net.kind_of?(@net_class)

      net.include?(self)
    end

    # @return [IPv6Addr] the "next" IPv6 address while enumerating hosts in a network, needed to be Comparable
    #
    def succ
      self.class.new(@addr + 1)
    end

    # Compare two IPv6 addresses. The address may be compared to another IPv6Addr object or a string representation of it
    #
    # @return [Boolean] true if the IP addresses match.
    #
    def ==(other)
      other = self.class.new(other) if !other.kind_of?(self.class)
      @addr == other.to_i
    end

    alias eql? ==
    alias === ==

    # Compare two IPv6 addresses. This is used just to implement hosts enumeration since there is no real ordering
    #
    def <=>(other)
      other = self.class.new(other) if !other.kind_of?(self.class)
      @addr <=> other.to_i
    end

    # Sum n to the host part and return a new IPv6Addr. Note that there is no check that the produced IP address is valid
    # and in the same network.
    #
    def +(n)
      self.class.new(@addr + n)
    end

    # Subtract n to the host part and return a new IPv6Addr. Note that there is no check that the produced IP address is valid
    # and in the same network.
    #
    def -(n)
      self.class.new(@addr - n)
    end

    # Bitwise or
    #
    def |(n)
      self.class.new(@addr | n)
    end

    # Bitwise and
    #
    def &(n)
      self.class.new(@addr & n)
    end

    # Mask this address with the specified mask (equivalent to a bitwise and)
    #
    def mask(mask)
      self.class.new(@addr & mask)
    end

    # Mask this address with the specified mask (equivalent to a bitwise and) and set ourself with resulting value
    #
    def mask!(mask)
      @addr &= mask
      self
    end

    # @return [Integer] an integer (host-byte-order) representation of the IP address
    #
    def to_i
      @addr
    end

    # @return [String] a human-readable representation of the IP address
    #
    def inspect
      "#<%#{self.class.name}:#{to_s}>"
    end

    # @return [Integer] a hash value to use an IP address as a key
    #
    def hash
      @addr
    end
  end

end