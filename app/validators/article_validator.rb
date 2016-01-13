class ArticleValidator < ActiveModel::Validator
  def validate(record)
    if record.published && !record.timestamp
      record.errors[:base] << "Article cannot be published without an associated timestamp"
    end
  end
end
