class PodcastSerializer < ActiveModel::Serializer
  attributes :id, :title, :end_time, :bitrate, :published, :created_at, :updated_at
  attribute :podcast_file_url, key: :podcast_file

  belongs_to :user
end
