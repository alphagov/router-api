class ApplicationController < ActionController::API
  include GDS::SSO::ControllerMethods
  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :error_404

protected

  def error_404
    render status: :not_found, plain: "Not found"
  end

  def parse_json_request
    @request_data = JSON.parse(request.body.read).with_indifferent_access
  rescue JSON::ParserError
    head :bad_request
  end
end
