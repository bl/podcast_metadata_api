class JsonSerializer
  def JsonSerializer.serialize(type, args, options = {})
    return unless args

    args_hash = args.to_hash.map do |k, v|
      if v.respond_to? :map
        v.map do |msg|
          { id: k, detail: msg }.merge options
        end
      else
        { id: k, detail: v }.merge options
      end
    end.flatten

    { type => args_hash }.to_json
  end
end
