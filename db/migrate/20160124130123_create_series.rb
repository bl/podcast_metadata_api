class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.string :title
      t.boolean :published, default: false
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
