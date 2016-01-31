require 'taglib'

class Podcast < ActiveRecord::Base
  before_validation :initialize_metadata

  belongs_to :series
  has_many :timestamps, dependent: :destroy

  mount_uploader :podcast_file, PodcastFileUploader

  validates :title,         presence: true,
                            length: { maximum: 100 }
  #TODO: look into carrierwave's validation
  # possibly redundant presence check
  validates :podcast_file,  presence: true
  validates :series,        presence: true
  validates :end_time,      presence: true, 
                            numericality: { gerater_than_or_equal_to: 5 }
  validates :bitrate,       presence: true,
                            numericality: { gerater_than_or_equal_to: 0 }

  scope :filter_by_title, lambda { |keyword|
    where("lower(title) LIKE ?", "%#{keyword.downcase}%")
  }

  scope :above_or_equal_to_end_time, lambda { |end_time|
    where("end_time >= ?", end_time)
  }

  scope :below_or_equal_to_end_time, lambda { |end_time|
    where("end_time <= ?", end_time)
  }

  def Podcast.search(params = {})
    podcasts = Podcast.all
    if params[:user_id].present?
      user = User.find_by id: params[:user_id]
      podcasts = user.podcasts if user
    end
    if params[:series_id].present?
      series = Series.find_by id: params[:series_id]
      podcasts = series.podcasts if series
    end
    podcasts = podcasts.filter_by_title(params[:title]) if params[:title].present?
    podcasts = podcasts.above_or_equal_to_end_time(params[:min_end_time].to_i) if params[:min_end_time].present?
    podcasts = podcasts.below_or_equal_to_end_time(params[:max_end_time].to_i) if params[:max_end_time].present?

    podcasts
  end

  private
    
  def initialize_metadata
    TagLib::FileRef.open(self.podcast_file.current_path) do |file|
      if file.null?
        self.errors[:podcast_file] = "is not a valid audio file"
      else
        prop = file.audio_properties
        self.end_time = prop.length
        self.bitrate = prop.bitrate
      end
    end
  end
end
