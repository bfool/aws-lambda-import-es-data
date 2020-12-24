require_relative './helpers/initializer'

def handler(event:, context:)
  bucket = event['Records'][0]['s3']['bucket']['name']
  key = event['Records'][0]['s3']['object']['key']

  reader = Reader.new(bucket, key)
  data = []

  reader.each do |record|
    data << { index: { data: JSON.parse(Base64.decode64(record[0])).inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo} } }

    if data.length >= 1000
    	import_data(data)
    	data = []
    end
  end

  import_data(data) if data.any?

end

def import_data(data)
  ElasticsearchClient.es_target.bulk(index: ENV['ES_INDEX'], type: 'doc', body: data)
end
