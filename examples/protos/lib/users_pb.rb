# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: users.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("users.proto", :syntax => :proto3) do
    add_message "organization.service.User" do
      optional :id, :int64, 1
      optional :name, :string, 2
      optional :age, :int32, 3
      optional :profile, :message, 4, "organization.service.Profile"
    end
    add_message "organization.service.Profile" do
      optional :id, :int64, 1
      optional :introduction, :string, 2
    end
  end
end

module UsersPb
  User = Google::Protobuf::DescriptorPool.generated_pool.lookup("organization.service.User").msgclass
  Profile = Google::Protobuf::DescriptorPool.generated_pool.lookup("organization.service.Profile").msgclass
end
