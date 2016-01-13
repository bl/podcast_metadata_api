class V1::ArticlesController < ApplicationController

  def show
    @article = Article.find_by id: params[:id]
    render json: { errors: "Invalid article" }, status: 403 and return unless @article

    render json: @article
  end

  def index
    @articles = Article.all
    render json: @articles
  end
end
