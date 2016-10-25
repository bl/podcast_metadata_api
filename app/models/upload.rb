class Upload < ActiveRecord::Base
  before_validation :generate_id, unless: -> { chunk_id.present? }
  before_validation :set_chunk_size, unless: -> { chunk_size.present? }
  before_destroy { ChunkedUpload.new(self).cleanup }

  belongs_to :subject, polymorphic: true

  validates :chunk_id,      presence: true
  validates :chunk_size,    presence: true
  validates :total_size,    presence: true,
                            numericality: { greater_than: 0 }
  validates :ext,           presence: true

  validates :subject,       presence: true
  validates :subject_type,  inclusion: { in: %w(Podcast) }

  def self.CHUNK_SIZE
    2**20
  end

  def progress
    progress_size / total_size.to_d * 100
  end

  def progress_size
    chunk.size
  end

  def chunk
    @chunk ||= File.open(file_dir, 'ab')
  end

  def finished?
    chunk.size == total_size
  end

  def file_dir
    store_dir(filename)
  end

  def store_dir(filename = nil)
    dir = "#{Rails.root.to_path}/public/chunked_uploads/#{resource_dir}"
    filename ? "#{dir}/#{filename}" : dir
  end

  def filename
    "#{chunk_id}.#{ext}"
  end

  private

  def resource_dir
    "#{subject.class.to_s.underscore}/#{subject.id}"
  end

  def generate_id
    self.chunk_id = SecureRandom.hex
  end

  def set_chunk_size
    self.chunk_size = Upload.CHUNK_SIZE
  end
end
