class Article < ActiveRecord::Base
  belongs_to :author, class_name: 'User'

  has_many :timestamps

  validates :author, presence: true
  validates :content, presence: true
  validates_with ArticleValidator

  # order articles in descending published date order on default scope
  default_scope -> { order(published_at: :desc) }

  # filter all articles by the patterns:
  #   published: {true/false} : only published/unpublished
  #   user_id: {id} : only articles owned by user_id
  def Article.search(params = {})
    articles = Article.all

    if params[:user_id].present?
      user = User.find_by id: params[:user_id]
      articles = articles.where(author_id: user.id) if user
    end

    # perform publishable searches
    articles = PublishableSearch.new(articles).search(params)
  end
end
