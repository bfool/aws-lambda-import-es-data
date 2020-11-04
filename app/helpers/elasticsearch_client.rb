require 'faraday_middleware/aws_sigv4'

class ElasticsearchClient
  class << self

    def es_target
      connect(url: ENV["ES_ADDRESS_URL"])
    end

    private

    def connect(url: "")
      return nil if url.empty?

      Elasticsearch::Client.new url: url do |f|
        f.request :aws_sigv4,
          credentials: Aws::Credentials.new(ENV['ES_AWS_ACCESS_KEY'], ENV['ES_AWS_SECRET_ACCESS_KEY']),
          service: "es",
          region: 'us-east-1'
      end
    end
  end
end
