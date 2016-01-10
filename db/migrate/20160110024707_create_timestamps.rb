class CreateTimestamps < ActiveRecord::Migration
  def change
    create_table :timestamps do |t|
      t.integer :start_time
      t.integer :end_time
      t.references :podcast, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
