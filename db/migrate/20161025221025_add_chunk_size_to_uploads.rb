class AddChunkSizeToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :chunk_size, :int
  end
end
