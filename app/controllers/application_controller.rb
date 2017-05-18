class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

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
