class TimestampValidator < ActiveModel::Validator
  def validate(record)

    # validate end_time is greater than start_time
    if record.end_time && record.start_time &&
       record.end_time <= record.start_time
      record.errors[:end_time] << "must be less than start time"
    end

    times = Array.new
    times.push 'end'    if record.end_time
    times.push 'start'  if record.start_time

    # validate if present, start/end_time is within podcast length
    if record.podcast
      times.each do |time|
        if record.send("#{time}_time") >= record.podcast.end_time
          record.errors["#{time}_time"] = "must be within podcast length"
        end
      end
    end
  end
end
