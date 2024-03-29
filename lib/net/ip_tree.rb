# frozen_string_literal: true
#
# Copyright (C) 2014-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Net

  # This class implements a binary tree in which to organize a set of networks
  #
  # Please note that if the tree is created with an IPv6 root all the subsequent operations will be
  # IPv6 only and viceversa.
  #
  class IPTree

    attr_accessor :l
    attr_accessor :r
    attr_accessor :network
    attr_accessor :used

    # Create a new tree object setting the specified network as the root
    #
    # @param net [Net::IPNet, String] Root network. If a string is specified the address family will be deducted
    # @param used [Boolean]           used mainly internally when creating support nodes.
    #
    def initialize(net = '::/0', used = false)

      if net.respond_to?(:each)
        initialize(net.first, used)

        net.each do |x|
          next if x.eql?(net.first)
          add(x)
        end

        return
      end

      @used = used

      if net.kind_of?(IPNet)
        @network = net
      else
        begin
          @network = IPv6Net.new(net)
        rescue ArgumentError
          @network = IPv4Net.new(net)
        end
      end
    end

    class NetworkAlreadyPresent < StandardError ; end
    class NetworkNotContained < StandardError ; end

    # Add a new network to the tree
    #
    # @param otehr [Net::IPNet, String] Network or array of networks to add
    #
    # Raises ArgumentError if network is already present in the tree
    # Raises ArgumentError if network is outside the root
    #
    def add(other)

      if other.respond_to?(:each)
        other.each { |x| add(x) }
        return
      end

      other = @network.class.new(other) unless other.kind_of?(@network.class)

      if other == @network
        raise NetworkAlreadyPresent, "Network #{other} already present in tree" if @used

        @used = true
        return
      end

      if !(other < @network)
        raise NetworkNotContained, "Network #{other} not contained in #{@network}"
      end

      if (other.prefix.to_i & (1 << (@network.max_length - (@network.length + 1))) == 0)
        if !@l
          @l = IPTree.new(@network.class.new(
                 :prefix => @network.prefix,
                 :length => @network.length + 1), false)
        end

        @l.add(other)
      else
        if !@r
          @r = IPTree.new(@network.class.new(
                 :prefix => @network.prefix | (1 << (@network.max_length - (@network.length + 1))),
                 :length => @network.length + 1), false)
        end

        @r.add(other)
      end

      self
    end

    # Returns a list of networks in the tree
    #
    def networks(opts = {})
      res = []
      res << @network if @used
      res += @l.networks if @l
      res += @r.networks if @r
      res
    end

    # Return a list of biggest contiguous subnets not used
    #
    def free_space(max_length = 128)

      return [] if @used
      return [@network] if !@l && !@r
      return [] if @network.length >= max_length

      res = []

      if @l
        res += @l.free_space(max_length)
      else
        res << @network.class.new(
                 :prefix => @network.prefix,
                 :length => @network.length + 1)
      end

      if @r
        res += @r.free_space(max_length)
      else
        res << @network.class.new(
                 :prefix => @network.prefix | (1 << (@network.max_length - (@network.length + 1))),
                 :length => @network.length + 1)
      end

      res
    end

    # Pick the smallest suitable free subnet
    #
    def pick_free(length, range = nil)
      fs = free_space(length)

      fs.select! { |x| x.first_ip <= range.last && x.last_ip >= range.first } if range
      fs.sort!

      return nil if fs.empty?
      return @network.class.new(:prefix => fs.first.prefix, :length => length) if !range

      fs.each do |freenet|
        net = @network.class.new(:prefix => freenet.prefix > range.first ? freenet.prefix : range.first,
                                 :length => length)

        net = net.succ if net.first_ip < range.first

        return net if net.last_ip <= range.last
      end

      nil
    end

    def find(net)

      net = @network.class.new(net) unless net.kind_of?(@network.class)

      if @network == net
        self
      elsif (net.prefix.to_i & (1 << (@network.max_length - (@network.length + 1))) == 0)
        @l ? @l.find(net) : nil
      else
        @r ? @r.find(net) : nil
      end
    end

    def summarize!
      raise NoMethodError, 'To be implemented'
    end

    def to_s(indent = 0)
      s = String.new
      s << @l.to_s(indent + (@used ? 2 : 0)) if @l
      s << @r.to_s(indent + (@used ? 2 : 0)) if @r
      s = (' ' * indent) + @network.to_s + " *\n" + s if @used
      s
    end
  end

end
