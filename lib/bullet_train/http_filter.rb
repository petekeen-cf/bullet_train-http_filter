require_relative './http_filter/version'
require_relative './http_filter/resolver'
require_relative './http_filter/uri'

module BulletTrain
  module HTTPFilter
    DEFAULT_BLOCKED_CIDRS = [
      # RFC 1918 IPv4 private address ranges
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",

      # RFC 4193 unique local unicast addresses (i.e. private range)
      "fc00::/7",

      # RFC 6598 IPv4 CGNAT-specific address range
      "100.64.0.0/10",

      # localhost
      "127.0.0.0/8",
      "::1",

      # multicast https://www.iana.org/assignments/multicast-addresses/multicast-addresses.xhtml
      "224.0.0.0/4",

      # AWS metadata endpoint
      "169.254.169.254/32",
    ]
    
    DEFAULT_CONFIG = {
      blocked_cidrs: DEFAULT_BLOCKED_CIDRS,
      allowed_cidrs: [],
      blocked_hostnames: ["localhost"],
      allowed_hostnames: [],
      public_resolvers: %w[8.8.8.8 1.1.1.1],
      allowed_schemes: %w[http https],
      custom_allow_callback: nil,
      custom_block_callback: nil,
      cache: nil,
    }

    class << self
      def config
        @config ||= DEFAULT_CONFIG

        if block_given?
          yield @config
        end

        @config
      end
    end
  end
end


