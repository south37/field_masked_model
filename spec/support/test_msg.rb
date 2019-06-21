require 'google/protobuf/timestamp_pb'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "test_msg.ClassA" do
    optional :id, :int64, 1
    optional :name, :string, 2
    optional :created_at, :message, 3, "google.protobuf.Timestamp"
    optional :class_b, :message, 4, "test_msg.ClassB"
    repeated :class_c_list, :message, 5, "test_msg.ClassC"
  end
  add_message "test_msg.ClassB" do
    optional :id, :int64, 1
    optional :type, :string, 2
  end
  add_message "test_msg.ClassC" do
    optional :id, :int64, 1
    optional :role, :string, 2
    optional :_op, :string, 3
    repeated :class_d_list, :message, 4, "test_msg.ClassD"
  end
  add_message "test_msg.ClassD" do
    optional :id, :int64, 1
    optional :not_model, :message, 2, "test_msg.NotModelClass"
  end
  add_message "test_msg.NotModelClass" do
    optional :value, :string, 1
  end
end

module TestMsg
  ClassA = Google::Protobuf::DescriptorPool.generated_pool.lookup("test_msg.ClassA").msgclass
  ClassB = Google::Protobuf::DescriptorPool.generated_pool.lookup("test_msg.ClassB").msgclass
  ClassC = Google::Protobuf::DescriptorPool.generated_pool.lookup("test_msg.ClassC").msgclass
  ClassD = Google::Protobuf::DescriptorPool.generated_pool.lookup("test_msg.ClassD").msgclass
  NotModelClass = Google::Protobuf::DescriptorPool.generated_pool.lookup("test_msg.NotModelClass").msgclass
end
