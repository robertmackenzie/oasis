require "ostruct"

class RequestView < SimpleDelegator
  def headers
    normalized_headers = super.map { |k, v|
      [normalize_header_key(k), v]
    }.to_h

    OpenStruct.new(normalized_headers)
  end

  private

  # from Content-Type to content_type
  def normalize_header_key(string)
    string.downcase.gsub("-", "_")
  end
end
