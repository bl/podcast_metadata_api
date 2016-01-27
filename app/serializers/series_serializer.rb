class SeriesSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :published, :created_at, :updated_at

  belongs_to :user
  has_many :podcasts
end
