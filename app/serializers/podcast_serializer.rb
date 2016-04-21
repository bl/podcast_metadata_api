class PodcastSerializer < PublishableSerializer
  attributes :id, :title, :end_time, :bitrate, :created_at, :updated_at
  attribute :podcast_file_url, key: :podcast_file

  belongs_to :series
  has_many :timestamps
end
