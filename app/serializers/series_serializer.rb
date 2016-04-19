class SeriesSerializer < PublishableSerializer
  attributes :id, :title, :description, :created_at, :updated_at

  belongs_to :user
  has_many :podcasts
end
