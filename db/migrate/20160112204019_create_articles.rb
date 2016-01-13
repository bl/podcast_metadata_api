class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.text :content
      t.boolean :published, default: false
      t.references :author, index: true, foreign_key: true
      t.references :timestamp, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
