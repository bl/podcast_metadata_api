class AddDescriptionToSeries < ActiveRecord::Migration
  def change
    add_column :series, :description, :text
  end
end
