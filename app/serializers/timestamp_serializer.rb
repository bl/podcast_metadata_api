class TimestampSerializer < ActiveModel::Serializer
  attributes :id, :start_time, :end_time, :created_at, :updated_at

  belongs_to :podcast
end
