class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery :with => :null_session

  rescue_from MongoMapper::DocumentNotFound, :with => :error_404

  protected

  def error_404
    render :status => 404, :text => "Not found"
  end
end
