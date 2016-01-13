class AddArticleReferenceToTimestamps < ActiveRecord::Migration
  def change
    add_reference :timestamps, :article, index: true, foreign_key: true
  end
end
