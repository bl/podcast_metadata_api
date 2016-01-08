class Podcast < ActiveRecord::Base
  belongs_to :user

  validates :title,       presence: true,
                          length: { maximum: 100 }
  validates :podcast_url, presence: true
  validates :user_id,     presence: true

  private
    
end
