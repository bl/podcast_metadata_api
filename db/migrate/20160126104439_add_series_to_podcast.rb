class AddSeriesToPodcast < ActiveRecord::Migration
  def change
    remove_reference :podcasts, :user, index: true, foreign_key: true
    add_reference :podcasts, :series, index: true, foreign_key: true
  end
end
