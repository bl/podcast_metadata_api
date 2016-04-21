class Api::V1::ArticlesController < Api::V1::PublishableController
  prepend_before_action :valid_article, only: [:show]
  before_action :logged_in_user,  only: [:create, :publish, :unpublish, :update, :destroy]
  before_action :correct_article, only: [:publish, :unpublish, :update, :destroy]

  def show
    render json: @article
  end

  def index
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

  protected

  # return the resource (used in base Publishable class)
  def resource
    @article
  end

  private

  # verify article exists based on provided id
  def valid_article
    @article ||= Article.find_by id: params[:id]
    render json: ErrorSerializer.serialize(article: "is invalid"), status: 422 and return unless @article
  end

  def article_params
    params.require(:article).permit(:content)
  end

  def correct_article
    @article ||= current_user.articles.find_by id: params[:id]
    render json: ErrorSerializer.serialize(article: "is invalid"), status: 422 unless @article
  end
end
