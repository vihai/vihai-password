# frozen_string_literal: true
#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Net

  class IPIfAddr

    # Automatically instantiate the correct network depending on the parsed string
    #
    # @return [IPv4Addr, IPv6Addr] the instantiated network
    #
    def self.new(*args, **kargs)
      if self == IPIfAddr
        begin
          IPv6IfAddr.new(*args, **kargs)
        rescue FormatNotRecognized
          IPv4IfAddr.new(*args, **kargs)
        end
      else
        super(*args, **kargs)
      end
    end

    # @return [IPNet] the network containing the interface address
    #
    def network
      @net_class.new(prefix: @addr & mask, length: @length)
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
      return false if !other
      return false if other.is_a?(IPIfAddr) && !(other.class <= self.class)
      begin
        other = self.class.new(other) if !other.kind_of?(self.class)
      rescue Net::FormatNotRecognized
        return false
      end

      @addr == other.addr && @length == other.length
    end
    alias eql? ==
    alias === ==

    # @return [String] a string representation of the interface address in the form a.b.c.d/nn
    #
    def to_s
      "#{address.to_s}/#{@length}"
    end

    # @return [String] a JSON representation of the interface address which is usually the result of #to_s
    #
    def to_json(*args)
      "\"#{to_s}\""
    end

    # @return [String] a representation of the object for to_json
    #
    def as_json(*args)
      to_s
    end

    # @return [Integer] a hash value to use an IF address as a key
    #
    def hash
      @addr.to_i * @length
    end

    # @return [Hash] a Hash with :addr and :length keys respectively containing the Integer representation of interface's
    #                address and network mask length
    #
    def to_h
      { addr: @addr, length: @length }
    end

    # @return [String] a human-readable representation of the object
    #
    def inspect
      "<#{self.class.to_s}:#{to_s}>"
    end

    # Returns a viable representation for encoders
    #
    def encode_with(coder)
      coder.scalar = to_s
      coder.tag = nil
    end
  end

end
