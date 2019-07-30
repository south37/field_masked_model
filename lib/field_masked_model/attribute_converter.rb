require "google/protobuf/timestamp_pb"
require "google/protobuf/wrappers_pb"

module FieldMaskedModel
  module AttributeConverter
    NULLABLE_TYPES = [
      Google::Protobuf::DoubleValue,
      Google::Protobuf::FloatValue,
      Google::Protobuf::Int64Value,
      Google::Protobuf::UInt64Value,
      Google::Protobuf::Int32Value,
      Google::Protobuf::UInt32Value,
      Google::Protobuf::BoolValue,
      Google::Protobuf::StringValue,
      Google::Protobuf::BytesValue,
    ].freeze

    class << self
      def convert(value)
        case value
        when Google::Protobuf::Timestamp
          timestamp_to_time(value)
        when *NULLABLE_TYPES
          value.value
        else
          # TODO(south37) Add conversion logic of other classes
          value
        end
      end

      # @param [Google::Protobuf::Timestamp] timestamp
      # @return [Time, ActiveSupport::TimeWithZone]
      def timestamp_to_time(timestamp)
        v = timestamp.nanos * (10 ** -9) + timestamp.seconds

        if Time.respond_to?(:zone) && Time.zone.respond_to?(:at)
          # Use ActiveSupport::TimeWithZone when it is available.
          Time.zone.at(v)
        else
          Time.at(v)
        end
      end
    end
  end
end
