class ArticleValidator < ActiveModel::Validator
  def validate(record)
    if record.published && record.timestamps.empty?
      record.errors[:base] << "Article cannot be published without an associated timestamp"
    end
  end
end
