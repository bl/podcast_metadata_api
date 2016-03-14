class AddPublisehdAtToResources < ActiveRecord::Migration
  def change
    add_column :podcasts, :published_at, :datetime, default: nil
    add_column :articles, :published_at, :datetime, default: nil
    add_column :series, :published_at, :datetime, default: nil
  end
end
