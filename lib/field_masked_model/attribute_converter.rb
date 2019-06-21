require "google/protobuf/timestamp_pb"

module FieldMaskedModel
  module AttributeConverter
    class << self
      def convert(value)
        case value
        when Google::Protobuf::Timestamp
          timestamp_to_time(value)
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
