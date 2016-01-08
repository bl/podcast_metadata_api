require 'taglib'

class Podcast < ActiveRecord::Base
  before_validation :initialize_metadata

  belongs_to :user

  mount_uploader :podcast_file, PodcastFileUploader

  validates :title,         presence: true,
                            length: { maximum: 100 }
  #TODO: look into carrierwave's validation
  # possibly redundant presence check
  validates :podcast_file,  presence: true
  validates :user_id,       presence: true
  validates :end_time,      presence: true
  validates :bitrate,       presence: true

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
