class BackendsController < ApplicationController

  before_filter :validate_slug

  def show
    @backend = Backend.find_by_backend_id!(params[:id])
    render :json => @backend.as_json
  end

  def update
    @backend = Backend.find_or_initialize_by_backend_id(params[:id])
    status_code = @backend.new_record? ? 201 : 200
    if @backend.update_attributes(params[:backend])
      render :json => @backend.as_json, :status => status_code
    else
      response_data = @backend.as_json.merge(:errors => @backend.errors.as_json)
      render :json => response_data, :status => 422
    end
  end

  private

  def validate_slug
    unless params[:id] =~ /\A[a-z0-9-]+\z/
      error_404
    end
  end
end
