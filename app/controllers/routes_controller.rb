class RoutesController < ApplicationController
  before_action :parse_json_request, only: [:update]
  before_action :ensure_route_keys, only: [:update]

  def show
    @route = Route.find_by(incoming_path: params[:incoming_path])
    render json: @route
  end

  def update
    route_details = @request_data[:route]
    incoming_path = route_details.delete(:incoming_path)
    tries = 3
    begin
      @route = Route.find_or_initialize_by(incoming_path:)
      status_code = @route.new_record? ? 201 : 200
      @route.update(route_details) || status_code = 422
    rescue Mongo::Error::OperationFailure
      (tries -= 1).positive? ? retry : raise
    end
    render json: @route, status: status_code
  end

  def destroy
    @route = Route.find_by(incoming_path: params[:incoming_path])
    if params[:hard_delete] == "true"
      @route.destroy!
    else
      @route.soft_delete
    end
    render json: @route
  end

  # TODO: remove RoutesController::commit once clients are cleaned up.
  def commit
    render plain: "DEPRECATED: there is no longer any need to call /routes/commit; it is a no-op."
  end

private

  def ensure_route_keys
    unless @request_data[:route].respond_to?(:has_key?) && @request_data[:route].key?(:incoming_path)
      render json: { "error" => "Required route keys (incoming_path and route_type) missing" }, status: :unprocessable_entity
    end
  end
end
