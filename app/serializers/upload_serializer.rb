class UploadSerializer < ActiveModel::Serializer
  attributes :chunk_id, :chunk_size, :total_size, :progress_size, :finished?
end
