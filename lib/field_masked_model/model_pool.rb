module FieldMaskedModel
  class ModelPool
    class << self
      def generated_pool
        @generated_pool ||= self.new
      end
    end

    def initialize
      @table = {}
    end

    # @param [Class] msgclass A class represents the protobuf message class
    # @return [Class] A class inheriting Models::Base
    def lookup(msgclass)
      @table[msgclass]
    end

    # @param [Class] msgclass A class represents the protobuf message class
    # @param [Class] modelclass A class inheriting Models::Base
    def add(msgclass, modelclass)
      @table[msgclass] = modelclass
    end
  end
end
