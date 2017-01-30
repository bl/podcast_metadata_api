require 'taglib'

class Podcast < ActiveRecord::Base
  # set metadata when podcast_file changes (either on create or update)
  before_validation :initialize_metadata, if: :updated_podcast_file?

  belongs_to :series
  has_many :timestamps, dependent: :destroy
  has_many :uploads,    as: :subject,
                        dependent: :destroy,
                        autosave: true

  mount_uploader :podcast_file, PodcastFileUploader

  validates :title,         presence: true,
                            length: { maximum: 100 }
  #TODO: look into carrierwave's validation
  validates :series,        presence: true
  validate :publishable
  with_options if:  -> { podcast_file.present? } do
    validates :end_time,    presence: true,
                            numericality: { greater_than_or_equal_to: 5 }
    validates :bitrate,     presence: true,
                            numericality: { greater_than_or_equal_to: 0 }
  end

  # order podcasts in descending published date order on default scope
  default_scope -> { order(published_at: :desc) }

  scope :filter_by_title, lambda { |keyword|
    where("lower(title) LIKE ?", "%#{keyword.downcase}%")
  }

  scope :above_or_equal_to_end_time, lambda { |end_time|
    where("end_time >= ?", end_time)
  }

  scope :below_or_equal_to_end_time, lambda { |end_time|
    where("end_time <= ?", end_time)
  }

  # TODO: move scopes to common class that all published resources explicitly use (ie try to avoid ambiguous include mixins)
  scope :greater_or_equal_to_published_at, lambda { |published_at|
    where("published_at >= ?", published_at)
  }

  scope :less_or_equal_to_published_at, lambda { |published_at|
    where("published_at <= ?", published_at)
  }

  def Podcast.search(params = {})
    # if both user_id and series_id are provided, only use series_id (more specific)
    if params[:user_id].present? && params[:series_id].present?
      params.delete :user_id
    end
    podcasts = PaginatedSearch.new(Podcast, Podcast.all).search(params)
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

    # perform publishable searches
    podcasts = PublishedSearch.new(podcasts).search(params)

    # perform search limiting
    podcasts = LimitedSearch.new(podcasts).search(params)
  end

  def clear_podcast_file
    remove_podcast_file!
    end_time = nil
    bitrate = nil
  end

  def store_podcast_file(file)
    self.podcast_file = file
    save
  end

  private
    
  def initialize_metadata
    TagLib::FileRef.open(self.podcast_file.current_path) do |file|
      if file.null?
        self.errors.add(:podcast_file, "is not a valid audio file")
        remove_podcast_file!
        assign_attributes(end_time: nil, bitrate: nil)
      else
        prop = file.audio_properties
        assign_attributes(end_time: prop.length, bitrate: prop.bitrate)
      end
    end
  end

  def updated_podcast_file?
    podcast_file.present? && podcast_file_changed?
  end

  def publishable
    if published? && !podcast_file.present?
      self.errors.add(:base, "Podcast cannot be published without an associated podcast file")
    end
  end
end
