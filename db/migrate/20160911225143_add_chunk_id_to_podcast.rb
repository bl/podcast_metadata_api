class AddChunkIdToPodcast < ActiveRecord::Migration
  def change
    add_column :podcasts, :chunk_id, :string
  end
end
