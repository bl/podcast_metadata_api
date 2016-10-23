class UploadSerializer < ActiveModel::Serializer
  attributes :chunk_id, :total_size, :progress_size, :finished?
end
