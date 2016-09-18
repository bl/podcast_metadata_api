class Upload < ActiveRecord::Base
  before_destroy { ChunkedUpload.new(self).cleanup }

  belongs_to :subject, polymorphic: true

  validates :total_size,  presence: true,
                          numericality: { greater_than: 0 }
  validates :ext, presence: true

  validates :subject, presence: true
  validates :subject_type, inclusion: { in: %w(Podcast) }
end
