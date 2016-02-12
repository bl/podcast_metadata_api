class Api::V1::TimestampsController < ApplicationController
  before_action :logged_in_user,    only: [:create, :update, :destroy]
  before_action :correct_podcast,   only: [:create]
  before_action :correct_timestamp, only: [:update, :destroy]

  def show
    @timestamp = Timestamp.find_by id: params[:id]
    render json: ErrorSerializer.serialize(timestamp: "is invalid"), status: 422 and return unless @timestamp

    render json: @timestamp
  end

  def index
    # return searched timestamps or an empty hash on no matches
    @timestamps = Timestamp.search(timestamp_search_params) || []
    render json: @timestamps
  end

  def create
    @timestamp = @podcast.timestamps.build(timestamp_params)
    if @timestamp.save
      render json: @timestamp, status: 201
    else
      render json: ErrorSerializer.serialize(@timestamp.errors), status: 422
    end
  end

  def update
    if @timestamp.update(timestamp_params)
      render json: @timestamp, status: 200
    else
      render json: ErrorSerializer.serialize(@timestamp.errors), status: 422
    end
  end

  def destroy
    @timestamp.destroy
    head 204
  end

  private

    def correct_timestamp
      @timestamp ||= Timestamp.find_by id: params[:id]
      unless @timestamp && @timestamp.podcast.series.user == current_user
        render json: ErrorSerializer.serialize(timestamp: "is invalid"), status: 422
      end
    end
    
    def timestamp_params
      params.require(:timestamp).permit(:start_time, :end_time)
    end

    def timestamp_search_params
      params.permit(:podcast_id)
    end
end
