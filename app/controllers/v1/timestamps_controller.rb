class V1::TimestampsController < ApplicationController
  before_action :logged_in_user,  only: [:create]
  before_action :correct_user,    only: [:create]
  before_action :correct_podcast, only: [:create]

  def show
    @timestamp = Timestamp.find_by id: params[:id]
    render json: { errors: "Invalid timestamp" }, status: 403 and return unless @timestamp

    render json: @timestamp
  end

  def index
    @timestamps = Timestamp.all
    render json: @timestamps
  end

  def create
    @timestamp = @podcast.timestamps.build(timestamp_params)
    if @timestamp.save
      render json: @timestamp, status: 201
    else
      render json: { errors: @timestamp.errors }, status: 422
    end
  end

  private

    def correct_user
      render json: { errors: "Invalid user" },
             status: 403 unless logged_in?
    end

    def correct_podcast
      @podcast ||= current_user.podcasts.find_by id: params[:podcast_id]
      render json: { errors: "Invalid podcast" }, status: 403 unless @podcast
    end
    
    def timestamp_params
      params.require(:timestamp).permit(:start_time, :end_time)
    end
end
