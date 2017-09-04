class ApplicationController < ActionController::API
  rescue_from Mongoid::Errors::DocumentNotFound, with: :error_404

  protected

  def error_404
    render status: 404, plain: "Not found"
  end

  def parse_json_request
    @request_data = JSON.parse(request.body.read).with_indifferent_access
  rescue JSON::ParserError
    head :bad_request
  end
end
