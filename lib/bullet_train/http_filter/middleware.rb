require 'excon'

module BulletTrain
  module HTTPFilter
    class Middleware < Excon::Middlware::Base
      def request_call(datum)
        datum[:query] = Excon::Utils.query_string(datum)[1..-1]
        
        BulletTrain::HTTPFilter::URI.parse(datum)

        super
      end
    end
  end
end
