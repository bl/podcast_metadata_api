class ArticleSerializer < PublishableSerializer
  attributes :id, :content, :created_at, :updated_at

  # explicitly specify serializer due to :author alias
  belongs_to :author, serializer: UserSerializer
end
