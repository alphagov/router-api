require 'router_reloader'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from MongoMapper::DocumentNotFound, :with => :error_404

  protected

  def error_404
    render :status => 404, :text => "Not found"
  end

  def reload_routes_if_needed
    if @routes_need_reloading
      RouterReloader.reload
    end
  end
end
