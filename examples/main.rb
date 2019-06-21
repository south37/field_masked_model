require "field_masked_model"
require File.join(__dir__, "protos", "lib", "users_pb")

class User < FieldMaskedModel::Base
  msgclass UsersPb::User
end

class Profile < FieldMaskedModel::Base
  msgclass UsersPb::Profile
end

u = User.new(
  field_mask: Google::Protobuf::FieldMask.new(paths: ["id", "name", "profile.id", "profile.introduction"]),
  message:    UsersPb::User.new(id: 3, name: "Taro", profile: UsersPb::Profile.new(id: 4, introduction: "My name is Taro")),
)

p u
p u.id
p u.name
begin
  u.age
rescue => e
  p e
end
p u.profile
