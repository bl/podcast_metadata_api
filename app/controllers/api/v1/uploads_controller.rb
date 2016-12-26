class Api::V1::UploadsController < ApplicationController
  before_action :logged_in_user, only: [:show, :create]
  before_action :correct_parent, only: [:create]
  before_action :correct_upload, only: [:show, :create, :update]

  def show
    # TODO: use correct_podcast once implementation works
    #render json: @podcast.upload, status: 200
    binding.pry
    render json: @upload, status: 200
  end

  def create
    #@resource.podcasts.create()
  end

  def update
  end

  private

  def chunk_params
    params.require(:upload).permit(:total_size, :data)
  end

  def correct_parent
    @resource ||= current_user.podcasts.find_by id: params[:podcast_id]
    render json: ErrorSerializer.serialize(podcast: "is invalid"), status: 422 and return unless @resource
  end

  def correct_upload
    @upload ||= Upload.find_by id: params[:id]
    unless @upload && @upload.user == current_user
      render json: ErrorSerializer.serialize(upload: "is invalid"), status: 422
      return
    end
  end
end
