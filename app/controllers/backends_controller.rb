class BackendsController < ApplicationController
  before_action :validate_slug
  before_action :parse_json_request, only: [:update]

  def show
    @backend = Backend.find_by(backend_id: params[:id])
    render json: @backend
  end

  def update
    @backend = Backend.find_or_initialize_by(backend_id: params[:id])
    status_code = @backend.new_record? ? 201 : 200
    @backend.update_attributes(@request_data['backend']) || status_code = 422
    render json: @backend, status: status_code
  end

  def destroy
    @backend = Backend.find_by(backend_id: params[:id])
    status_code = 200
    @backend.destroy || status_code = 422
    render json: @backend, status: status_code
  end

  private

  def validate_slug
    error_404 unless params[:id] =~ /\A[a-z0-9-]+\z/
  end
end
