class AddPublishedAtIndexToPublishableResources < ActiveRecord::Migration
  def change
    add_index :podcasts, :published_at
    add_index :podcasts, [:title, :published_at]
    add_index :series, :published_at
    add_index :articles, :published_at
  end
end
