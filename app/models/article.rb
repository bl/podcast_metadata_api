class Article < ActiveRecord::Base
  belongs_to :author, class_name: 'User'

  has_many :timestamps

  validates :author, presence: true
  validates :content, presence: true
  validates_with ArticleValidator

  def Article.search(params = {})
    articles = Article.all
    if params[:user_id].present?
      user = User.find_by id: params[:user_id]
      articles = user.articles if user
    end

    articles
  end
end
