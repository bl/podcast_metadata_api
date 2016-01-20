class ErrorSerializer
  def ErrorSerializer.serialize(errors, options = {})
    return unless errors

    errors_hash = errors.to_hash.map do |k, v|
      if v.respond_to? :map
        v.map do |msg|
          { id: k, detail: msg }.merge options
        end
      else
        { id: k, detail: v }.merge options
      end
    end.flatten

    { Errors: errors_hash }.to_json
  end
end
