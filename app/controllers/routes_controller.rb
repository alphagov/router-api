require 'router_reloader'

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
      @route = Route.find_or_initialize_by(incoming_path: incoming_path)
      status_code = @route.new_record? ? 201 : 200
      @route.update_attributes(route_details) || status_code = 422
    rescue Mongo::Error::OperationFailure => e
      if e.message.start_with?(Route::DUPLICATE_KEY_ERROR) && (tries -= 1) > 0
        retry
      else
        raise
      end
    end
    render json: @route, status: status_code
  end

  def destroy
    @route = Route.find_by(incoming_path: params[:incoming_path])
    if params[:hard_delete] == "true"
      @route.destroy
    else
      @route.soft_delete
    end
    render json: @route
  end

  def commit
    if RouterReloader.reload
      render text: "Router reloaded"
    else
      render text: "Failed to reload all routers", status: 500
    end
  end

  private

  def ensure_route_keys
    unless @request_data[:route].respond_to?(:has_key?) && @request_data[:route].has_key?(:incoming_path)
      render json: {"error" => "Required route keys (incoming_path and route_type) missing"}, status: 422
    end
  end
end
