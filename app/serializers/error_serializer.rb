class ErrorSerializer
  def self.serialize(errors, options = {})
    JsonSerializer.serialize(:errors, errors, options)
  end
end
