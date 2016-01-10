class TimestampValidator < ActiveModel::Validator
  def validate(record)
    if record.end_time && record.start_time &&
       record.end_time <= record.start_time
      record.errors[:end_time] << "must be less than start time"
    end
  end
end
