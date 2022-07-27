require 'digest'
require 'resolv'

module BulletTrain
  module HTTPFilter
    ResolvedIp = Struct.new(:address, :ttl)

    class InvalidHostnameError < ArgumentError; end
    
    class Resolver
      def self.getaddress(hostname, should_cache: true, recurse_count: 0)
        config = BulletTrain::HTTPFilter.config
        cache = config[:cache]

        if recurse_count > 10
          raise InvalidHostnameError
        end
  
        begin
          return ResolvedIp.new(address: IPAddr.new(hostname), ttl: 0)
        rescue IPAddr::InvalidAddressError
          # this is fine, proceed with resolver path
        end
  
        cache_key = "bullet_train/http_filter/getaddress/#{Digest::SHA2.hexdigest(hostname)}"

        if should_cache && cache
          cached = cache.read(cache_key)
          if cached
            return cached == "invalid" ? nil : ResolvedIp.new(IPAddr.new(cached), 0)
          end
        end
  
        begin
          # This is sort of a half-recursive DNS resolver.
          # We can't implement a full recursive resolver using just Resolv::DNS so instead
          # this asks a public cache for the NS record for the given domain. Then it asks
          # the authoritative nameserver directly for the address and caches it according
          # to the returned TTL.
  
          ns_resolver = Resolv::DNS.new(nameserver: config[:public_resolvers])
          ns_resolver.timeouts = 1
  
          # recurse on the hostname to determine the appropriate nameserver
          parts = hostname.split(".")
          authoritative = []
          while authoritative.empty? && parts.length > 0
            authoritative = ns_resolver.getresources(parts.join("."), Resolv::DNS::Resource::IN::NS)
            parts.shift
          end
  
          if authoritative.empty?
            raise InvalidHostnameError
          end
  
          authoritative_resolver = Resolv::DNS.new(nameserver: [authoritative.sample.name.to_s])
          authoritative_resolver.timeouts = 1
  
          # first we try A
          resources = authoritative_resolver.getresources(hostname, Resolv::DNS::Resource::IN::A)
  
          # if it's empty try for a CNAME
          if resources.empty?
            resources = authoritative_resolver.getresources(hostname, Resolv::DNS::Resource::IN::CNAME)
            if resources.empty?
              # if we still have nothing fall through to invalid
              raise InvalidHostnameError
            end
  
            # recurse on the value of the CNAME
            result = getaddress(resources.first.name.to_s, recurse_count: recurse_count + 1, should_cache: should_cache)
            cache.write(cache_key, result.address.to_s, expires_in: result.ttl, race_condition_ttl: 5) if (should_cache && cache)
            return result
          end
  
          # grab a random IP from the returned set
          resource = resources.sample
  
          cache.write(cache_key, resource.address.to_s, expires_in: resource.ttl, race_condition_ttl: 5) if (should_cache && cache)
          ResolvedIp.new(IPAddr.new(resource.address.to_s), resource.ttl)
        rescue IPAddr::InvalidAddressError, InvalidHostnameError # standard:disable Lint/ShadowedException
          config[:cache].write(cache_key, "invalid", expires_in: 10.minutes, race_condition_ttl: 5) if (should_cache && cache)
          nil
        end        
      end
    end
  end
end
