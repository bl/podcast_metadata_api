class ArticleSerializer < ActiveModel::Serializer
  attributes :id, :content

  # explicitly specify serializer due to :author alias
  belongs_to :author, serializer: UserSerializer
end
