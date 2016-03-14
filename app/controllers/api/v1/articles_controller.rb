class Api::V1::ArticlesController < ApplicationController
  before_action :logged_in_user,  only: [:create, :update, :destroy]
  before_action :correct_article, only: [:update, :destroy]

  def show
    @article = Article.find_by id: params[:id]
    render json: ErrorSerializer.serialize(article: "is invalid"), status: 422 and return unless @article

    # display unpublished article only if logged_in user is the owner
    unless @article.published || (!@article.published && logged_in? && current_user.articles.exists?(@article.id))
      render json: ErrorSerializer.serialize(article: "is invalid"), status: 422 and return
    end

    render json: @article
  end

  def index

    # only logged in users viewing their own podcasts can search unpublished
    unless logged_in? && params[:user_id].present? && current_user.id == params[:user_id].to_i
      params.merge! published: true
    end

    @articles = Article.search(params)
    render json: @articles
  end

  def create
    @article = current_user.articles.build(article_params)
    if @article.save
      render json: @article, status: 201
    else
      render json: ErrorSerializer.serialize(@article.errors), status: 422
    end
  end

  def update
    if @article.update(article_params)
      render json: @article, status: 200
    else
      render json: ErrorSerializer.serialize(@article.errors), status: 422
    end
  end

  def destroy
    @article.destroy
    head 204
  end

  private

    def article_params
      params.require(:article).permit(:content)
    end

    def correct_article
      @article ||= current_user.articles.find_by id: params[:id]
      render json: ErrorSerializer.serialize(article: "is invalid"), status: 422 unless @article
    end
end
