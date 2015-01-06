require 'router_reloader'

class RoutesController < ApplicationController
  before_filter :parse_json_request, :only => [:update]
  before_filter :ensure_route_keys, :only => [:update]

  def show
    @route = Route.find_by(:incoming_path => params[:incoming_path], :route_type => params[:route_type])
    render :json => @route
  end

  def update
    route_details = @request_data[:route]
    @route = Route.find_or_initialize_by(:incoming_path => route_details.delete(:incoming_path), :route_type => route_details.delete(:route_type))
    status_code = @route.new_record? ? 201 : 200
    @route.update_attributes(route_details) or status_code = 422
    render :json => @route, :status => status_code
  end

  def destroy
    @route = Route.find_by(:incoming_path => params[:incoming_path], :route_type => params[:route_type])
    if params[:hard_delete] == "true"
      @route.destroy
    else
      @route.soft_delete
    end
    render :json => @route
  end

  def commit
    if RouterReloader.reload
      render :text => "Router reloaded"
    else
      render :text => "Failed to reload all routers", :status => 500
    end
  end

  private

  def ensure_route_keys
    unless @request_data[:route].respond_to?(:has_key?) and @request_data[:route].has_key?(:incoming_path) and @request_data[:route].has_key?(:route_type)
      render :json => {"error" => "Required route keys (incoming_path and route_type) missing"}, :status => 422
    end
  end
end
