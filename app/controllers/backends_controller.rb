class BackendsController < ApplicationController

  before_filter :validate_slug
  after_filter :reload_routes_if_needed, :only => [:update]

  def show
    @backend = Backend.find_by_backend_id!(params[:id])
    render :json => @backend
  end

  def update
    @backend = Backend.find_or_initialize_by_backend_id(params[:id])
    status_code = @backend.new_record? ? 201 : 200
    if @backend.update_attributes(params[:backend])
      @routes_need_reloading = status_code == 200
      render :json => @backend, :status => status_code
    else
      render :json => @backend, :status => 400
    end
  end

  def destroy
    @backend = Backend.find_by_backend_id!(params[:id])
    if @backend.destroy
      render :json => @backend
    else
      render :json => @backend, :status => 400
    end
  end

  private

  def validate_slug
    unless params[:id] =~ /\A[a-z0-9-]+\z/
      error_404
    end
  end
end
