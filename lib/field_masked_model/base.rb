require "fmparser"
require "google/protobuf"
require "google/protobuf/field_mask_pb"

require "field_masked_model/attribute_converter"
require "field_masked_model/model_pool"

module FieldMaskedModel
  class Base
    class << self
      attr_reader :msg, :model_pool, :inaccessible_error_callback

      # @param [Class] klass A class represents the protobuf message class
      # @param [<Symbol, String>] exclude_fields
      # @param [FieldMaskedModel::ModelPool] model_pool
      def msgclass(klass, exclude_fields: [], model_pool: ModelPool.generated_pool)
        if defined?(@msg)
          raise "msgclass is already registered!"
        end

        @model_pool = model_pool
        @model_pool.add(klass, self)

        exclude_fields.each do |field|
          exclude_field field
        end

        @msg = klass
        define_accessors!
      end

      # @param [Symbol, String] name
      def exclude_field(name)
        if defined?(@msg)
          Kernel.warn("exclude_field must be called before msgclass", uplevel: 1)
        end
        _excluded_fields << name.to_s
      end

      # @param [Proc] callback
      def set_inaccessible_error_callback(callback)
        @inaccessible_error_callback = callback
      end

      # @return [<Symbol, { Symbol => Array }>]
      def fields
        r = []
        children = {}
        self.entries.each do |entry|
          n = entry.name.to_sym
          type = self.dispatch(entry)
          case type
          when :attribute
            r << n
          when :association
            modelclass = @model_pool.lookup(entry.subtype.msgclass)
            children[n] = modelclass.fields
          when :repeated_association
            modelclass = @model_pool.lookup(entry.subtype.msgclass)
            children[n] = modelclass.fields
          end
        end
        r << children if children.size > 0
        r
      end

      # @return [<Google::Protobuf::FieldDescriptor>]
      def entries
        @msg.descriptor.entries.select do |e|
          !_excluded_fields.include?(e.name)
        end
      end

      # @param [Google::Protobuf::FieldDescriptor] entry
      # @return [Symbol]
      def dispatch(entry)
        case entry.type
        when :message
          m = @model_pool.lookup(entry.subtype.msgclass)
          # NOTE: If msgclass is not registered in ModelPool, we treat it
          # as a one of attribute classes.
          if m.nil?
            return :attribute
          end

          case entry.label
          when :repeated
            :repeated_association
          else
            :association
          end
        else # eum or scalar
          :attribute
        end
      end

     private

      def define_accessors!
        self.entries.each do |entry|
          n = entry.name.to_sym
          define_accessor!(name: n, entry: entry)
        end
      end

      def define_accessor!(name:, entry:)
        define_method(name) do
          validate!(name)

          ivar = :"@_#{name}"
          if instance_variable_defined?(ivar)
            next instance_variable_get(ivar)
          end

          v = @message.send(name)
          type = self.class.dispatch(entry)
          r =
            case type
            when :attribute
              AttributeConverter.convert(v)
            when :association
              if v.nil?
                nil
              else
                modelclass = self.class.model_pool.lookup(entry.subtype.msgclass)
                modelclass.new(field_mask_node: @fm_node.get_child(name), message: v)
              end
            when :repeated_association
              modelclass = self.class.model_pool.lookup(entry.subtype.msgclass)
              v.map do |vv|
                if vv.nil?
                  nil
                else
                  modelclass.new(field_mask_node: @fm_node.get_child(name), message: vv)
                end
              end
            end

          instance_variable_set(ivar, r)
        end
      end

      def _excluded_fields
        @_excluded_fields ||= Set.new
      end
    end

    # @param [Google::Protobuf::FieldMask, nil] field_mask_node
    # @param [FMParser::MessageNode, nil] field_mask_node
    # @param [Object] message represents the protobuf message object
    def initialize(field_mask: nil, field_mask_node: nil, message:)
      if field_mask.nil? && field_mask_node.nil?
        raise ArgumentError.new("missing keyword: field_mask or field_mask_node")
      end
      @fm_node = field_mask_node || FMParser.parse(paths: field_mask.paths, root: self.class.msg)
      @message = message

      @accessible_fields ||= Set.new(@fm_node.field_names)
    end

    # @return [Hash]
    def to_h
      r = {}
      self.class.entries.each do |entry|
        n = entry.name.to_sym
        next if !@accessible_fields.include?(n)

        v = self.send(n)
        type = self.class.dispatch(entry)
        case type
        when :attribute
          r[n] = v
        when :association
          if v.nil?
            r[n] = nil
          else
            r[n] = v.to_h
          end
        when :repeated_association
          r[n] = v.map(&:to_h)
        end
      end
      r
    end

    # @return [String]
    def inspect
      h = {}
      self.class.entries.each do |entry|
        n = entry.name.to_sym
        if !@accessible_fields.include?(n)
          h[n] = "-"
          next
        end

        v = self.send(n)
        type = self.class.dispatch(entry)
        case type
        when :attribute
          case v
          when NilClass
            h[n] = "nil"
          when String
            h[n] = "\"#{v}\""
          else
            h[n] = v
          end
        when :association
          case v
          when NilClass
            h[n] = "nil"
          else
            h[n] = v.class.name.split("::").last
          end
        when :repeated_association
          if v.size > 0
            h[n] = "[#{v[0].class.name.split("::").last}]"
          else
            h[n] = "[]"
          end
        end
      end
      "<#{self.class.name}#{h.map { |k, v| "\n #{k}: #{v}" }.join(',')}>"
    end

  private

    # @param [Symbol] field
    # @raise [FieldMaskedModel::InaccessibleError]
    def validate!(field)
      if !@accessible_fields.include?(field)
        if self.class.inaccessible_error_callback
          self.class.inaccessible_error_callback.call(field)
        else
          raise FieldMaskedModel::InaccessibleError.new("`#{field}` is not specified as paths in field_mask!")
        end
      end
    end
  end
end
