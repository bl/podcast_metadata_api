class V1::ArticlesController < ApplicationController
  before_action :logged_in_user,  only: [:create]

  def show
    @article = Article.find_by id: params[:id]
    render json: { errors: "Invalid article" }, status: 403 and return unless @article

    render json: @article
  end

  def index
    @articles = Article.all
    render json: @articles
  end

  def create
    @article = current_user.articles.build(article_params)
    if @article.save
      render json: @article, status: 201
    else
      render json: { errors: @article.errors }, status: 422
    end
  end

  private

    def article_params
      params.require('article').permit('content')
    end
end