class V1::TimestampsController < ApplicationController

  def show
    @timestamp = Timestamp.find_by id: params[:id]
    render json: { errors: "Invalid timestamp" }, status: 403 and return unless @timestamp

    render json: @timestamp
  end

  def index
    @timestamps = Timestamp.all
    render json: @timestamps
  end
end
