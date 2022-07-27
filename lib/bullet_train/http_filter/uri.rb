require 'addressable'

module BulletTrain
  module HTTPFilter
    class BlockedURIError < ArgumentError; end

    class URI < Addressable::URI
      attr_accessor :httpfilter_context

      def self.parse(uri, httpfilter_context: nil)
        parsed = super(uri)
        parsed.httpfilter_context = httpfilter_context

        raise BlockedURIError.new(uri) unless parsed.allowed?

        parsed
      end

      def initialize(options={})
        super

        if options[:httpfilter_context]
          self.httpfilter_context = options[:httpfilter_context]
        end
      end

      def allowed?
        config = BulletTrain::HTTPFilter.config
        hostname = self.hostname.downcase

        return false unless config[:allowed_schemes].include?(scheme)
  
        if config[:custom_allow_callback] != nil
          return true if config[:custom_allow_callback].call(self)
        end
  
        if config[:custom_block_callback] != nil
          return false if config[:custom_block_callback].call(self)
        end
  
        allowed_hostnames = config[:allowed_hostnames].dup
  
        allowed_hostnames.each do |allowed|
          if allowed.is_a?(Regexp)
            return true if allowed.match?(hostname)
          end
  
          return true if allowed == hostname
        end
  
        config[:blocked_hostnames].each do |blocked|
          if blocked.is_a?(Regexp)
            return false if blocked.match?(hostname)
          end
  
          return false if blocked == hostname
        end
  
        resolved_ip = Resolver.getaddress(hostname)
        return false if resolved_ip.nil?
  
        begin
          config[:allowed_cidrs].each do |cidr|
            return true if IPAddr.new(cidr).include?(resolved_ip.address)
          end
  
          config[:blocked_cidrs].each do |cidr|
            return false if IPAddr.new(cidr).include?(resolved_ip.address)
          end
        rescue IPAddr::InvalidAddressError
          return false
        end
  
        true
      end
    end
  end
end
