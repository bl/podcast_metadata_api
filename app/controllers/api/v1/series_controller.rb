class Api::V1::SeriesController < Api::V1::PublishableController
  prepend_before_action :valid_series, only: [:show]
  before_action :logged_in_user,  only: [:create, :publish, :unpublish, :update, :destroy]
  before_action :correct_series,  only: [:publish, :unpublish, :update, :destroy]

  def show
    render json: @series
  end

  def index
    @series = Series.search(params)
    render json: @series
  end

  def create
    @series = current_user.series.build(series_params)
    if @series.save
      render json: @series, status: 201
    else
      render json: ErrorSerializer.serialize(@series.errors), status: 422
    end
  end

  def update
    if @series.update(series_params)
      render json: @series, status: 200
    else
      render json: ErrorSerializer.serialize(@series.errors), status: 422
    end
  end

  def destroy
    @series.destroy
    head 204
  end

  protected

  # return the resource (used in base Publishable class)
  def resource
    @series
  end

  private

  def series_params
    params.require(:series).permit(:title, :description)
  end

  def correct_series
    @series ||= current_user.series.find_by id: params[:id]
    render json: ErrorSerializer.serialize(series: "is invalid"), status: 422 unless @series
  end

  def valid_series
    @series ||= Series.find_by id: params[:id]
    render json: ErrorSerializer.serialize(series: "is invalid"), status: 422 and return unless @series
  end
end
