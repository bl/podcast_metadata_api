class CreatePodcasts < ActiveRecord::Migration
  def change
    create_table :podcasts do |t|
      t.string :title
      t.string :podcast_url
      t.integer :end_time
      t.boolean :published, default: false
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :podcasts, :title
    add_index :podcasts, [:title, :created_at]
  end
end
