class ErrorSerializer
  def ErrorSerializer.serialize(errors, options = {})
    JsonSerializer.serialize(:errors, errors, options)
  end
end
