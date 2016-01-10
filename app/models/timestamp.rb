class Timestamp < ActiveRecord::Base
  belongs_to :podcast

  validates :podcast_id,  presence: true
  validates :start_time,  presence: true,
                          numericality: { greater_than_or_equal_to: 0 }
  validates_with TimestampValidator
end
