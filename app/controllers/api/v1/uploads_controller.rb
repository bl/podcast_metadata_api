class Api::V1::UploadsController < ApplicationController
  before_action :logged_in_user,   only: [:show, :create, :update, :destroy]
  before_action :correct_parent,   only: [:create]
  before_action :correct_upload,   only: [:show, :update, :destroy]
  before_action :completed_upload, only: [:update]

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
    chunked_upload = ChunkedUpload.new(@upload)
    chunked_upload.store_chunk(chunk_params[:data])

    if @upload.valid? && @upload.finished?
      chunked_upload.read do |completed_file|
        @upload.subject.store_podcast_file(completed_file)
      end
    end

    if @upload.subject.valid?
      render json: @upload, status: 200

      # cleanup after rendering above
      #chunked_upload.cleanup
    else
      render json: ErrorSerializer.serialize(@upload.subject.errors), status: 422
    end
  end

  def destroy
    @upload.destroy
    head 204
  end

  private

  def upload_params
    in_params = params.require(:upload).permit(:total_size, :ext)
  end

  def chunk_params
    # TODO smater params validation on :data as a file object (specifically audio)
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

  def chunked_upload
    @chunked_upload ||= ChunkedUpload.new(@upload)
  end

  def completed_upload
    errors = chunked_upload.validate_chunk(chunk_params[:data])
    if errors.present?
      render json: ErrorSerializer.serialize(errors), status: 422
      return
    end
  end
end
