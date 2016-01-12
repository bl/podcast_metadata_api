class V1::TimestampsController < ApplicationController
  before_action :logged_in_user,    only: [:create, :update]
  before_action :correct_user,      only: [:create, :update]
  before_action :correct_podcast,   only: [:create, :update]
  before_action :correct_timestamp, only: [:update]

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

  def update
    if @timestamp.update(timestamp_params)
      render json: @timestamp, status: 200
    else
      render json: { errors: @timestamp.errors }, status: 422
    end
  end

  private

    def correct_user
      render json: { errors: "Invalid user" },
             status: 403 unless logged_in?
    end

    def correct_timestamp
      @timestamp ||= @podcast.timestamps.find_by id: params[:id]
      render json: { errors: "Invalid timestamp" }, status: 403 unless @timestamp
    end
    
    def timestamp_params
      params.require(:timestamp).permit(:start_time, :end_time)
    end
end
