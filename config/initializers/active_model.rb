# active model serializer used to serialize json controller output
class ActiveModel::Serializer
  # enable JSON_API spec conforming serialization
  config.adapter = :json_api
end
