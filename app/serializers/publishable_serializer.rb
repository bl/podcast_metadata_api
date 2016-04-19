class PublishableSerializer < ActiveModel::Serializer
  attributes :published, :published_at
end
