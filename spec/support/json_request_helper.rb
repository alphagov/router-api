module JSONRequestHelper
  def put_json(path, attrs, headers = {})
    put path, attrs.to_json, {"Content-Type" => "application/json"}.merge(headers)
  end
end

RSpec.configuration.include JSONRequestHelper, :type => :request
