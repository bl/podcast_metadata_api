class Api::V1::UploadsController < ApplicationController
  before_action :logged_in_user, only: [:show, :create]
  before_action :correct_parent, only: [:create]
  before_action :correct_upload, only: [:show, :update]

  def show
    render json: @upload, status: :ok
  end

  def create
    @upload = @resource.uploads.build(
      upload_params.merge(user: @resource.series.user)
    )
    # TODO: look into stronger parameters-like type conercion instead of this
    @upload.total_size = upload_params[:total_size].to_i if upload_params[:total_size].present?
    if @upload.save
      render json: @upload, status: :created
    else
      render json: ErrorSerializer.serialize(@upload.errors), status: :unprocessable_entity
    end
  end

  def update
  end

  private

  def upload_params
    in_params = params.require(:upload).permit(:total_size, :ext)
  end

  def chunk_params
    params.require(:upload).permit(:data)
  end

  def correct_parent
    @resource ||= current_user.podcasts.find_by id: params[:podcast_id]
    # TODO: resolve once podcast.user is an association
    unless @resource && @resource.series.user == current_user
      render json: ErrorSerializer.serialize(podcast: "is invalid"), status: :unprocessable_entity
      return
    end
  end

  def correct_upload
    @upload ||= Upload.find_by id: params[:id]
    unless @upload && @upload.user == current_user
      render json: ErrorSerializer.serialize(upload: "is invalid"), status: :unprocessable_entity
      return
    end
  end
end
