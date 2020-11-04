class Reader
  attr_reader :bucket, :key, :file
  def initialize(bucket, key, tmp_file = Tempfile.new('tmp_records'))
    @bucket = bucket
    @key = key
    @file = tmp_file
    @file.sync = true
  end

  def each
    read_s3_file do |item|
      yield(item)
    end
  end

  private

  def client
    @client ||= Aws::S3::Client.new(region: "us-east-1")
  end

  def read_s3_file
    client.select_object_content(
      bucket: bucket,
      key: key,
      expression: 'SELECT * FROM S3Object[*].rawData',
      expression_type: 'SQL',
      input_serialization: {
        json: {
          type: 'DOCUMENT'
        }
      },
      output_serialization: {
        csv: {
          field_delimiter: '^'
        }
      },
      request_progress: {
        enabled: false
      }
    ) do |stream|
      stream.on_error_event do |event|
        raise event
      end
  
      stream.on_event do |event|
        case event.event_type
        when :records
          file.write event.payload.read
        when :end
          output = []
          CSV.foreach(file, headers: false, col_sep: '^') do |row|
            yield(row)
          end
        end
      end
    end
  end
end