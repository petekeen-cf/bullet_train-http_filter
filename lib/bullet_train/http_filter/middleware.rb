require 'excon'

module BulletTrain
  module HTTPFilter
    class Middleware < Excon::Middlware::Base
      def request_call(datum)
        datum[:query] = Excon::Utils.query_string(datum)[1..-1]

        uri = BulletTrain::HTTPFilter::URI.new(datum)
        
        unless uri.allowed?
          raise BulletTrain::HTTPFilter::BlockedURIError.new(uri.to_s)
        end

        super
      end
    end
  end
end

module Excon
  VALID_REQUEST_KEYS << :httpfilter_context
  VALID_CONNECTION_KEYS << :httpfilter_context
