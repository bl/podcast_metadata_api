class Article < ActiveRecord::Base
  belongs_to :author, class_name: 'User'
  belongs_to :timestamp

  validates :author, presence: true
  validates :content, presence: true
  validates_with ArticleValidator
end
