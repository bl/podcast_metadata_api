class Timestamp < ActiveRecord::Base
  belongs_to :podcast
  belongs_to :article

  validates :podcast_id,  presence: true
  validates :start_time,  presence: true,
                          numericality: { greater_than_or_equal_to: 0 }
  validates_with TimestampValidator

  # returns nil when podcast is not found
  def Timestamp.search(params = {})
    timestamps = nil
    if params[:podcast_id].present?
      podcast = Podcast.find_by id: params[:podcast_id]
      timestamps = podcast.timestamps if podcast
    end

    timestamps
  end

end
