class AddPasswordResetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reset_digest, :string
    add_column :users, :reset_at, :datetime
  end
end
