#TODO: resolve duplicate UserSerializer & UserAuthSerializer via instance_options once available on stable branch
class UserAuthSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :auth_token, :created_at, :updated_at

  has_many :series
end
