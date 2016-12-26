class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :chunk_id, null: false
      t.integer :total_size
      t.string :ext
      t.references :subject, polymorphic: true, index: true
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :uploads, :chunk_id, unique: true
  end
end
