require "support/test_msg"

describe FieldMaskedModel::Base do
  let(:class_a) {
    Class.new(FieldMaskedModel::Base) do
      msgclass TestMsg::ClassA
    end
  }
  let(:class_b) {
    Class.new(FieldMaskedModel::Base) do
      msgclass TestMsg::ClassB
    end
  }
  let(:class_c) {
    Class.new(FieldMaskedModel::Base) do
      msgclass TestMsg::ClassC, exclude_fields: [:_op]
    end
  }
  let(:class_d) {
    Class.new(FieldMaskedModel::Base) do
      msgclass TestMsg::ClassD
    end
  }

  before do
    stub_const("ClassA", class_a)
    stub_const("ClassB", class_b)
    stub_const("ClassC", class_c)
    stub_const("ClassD", class_d)
  end

  describe "#initialize" do
    context "when only id is specified as field_mask" do
      it "creates a model object with id" do
        f = Google::Protobuf::FieldMask.new(paths: ["id"])
        m = TestMsg::ClassA.new({ id: 1 })
        a = ClassA.new(field_mask: f, message: m)
        expect(a.id).to eq 1
        expect { a.name }.to raise_error(FieldMaskedModel::InaccessibleError)
        expect { a.class_b }.to raise_error(FieldMaskedModel::InaccessibleError)
        expect { a.class_c_list }.to raise_error(FieldMaskedModel::InaccessibleError)
      end
    end

    context "when only class_b.type is specified as field_mask" do
      it "creates a model object with class_b.type" do
        f = Google::Protobuf::FieldMask.new(paths: ["class_b.type"])
        m = TestMsg::ClassA.new({
          id: 1,
          class_b: {
            id: 2,
            type: "Power",
          }
        })
        a = ClassA.new(field_mask: f, message: m)
        expect { a.id }.to raise_error(FieldMaskedModel::InaccessibleError)
        expect { a.name }.to raise_error(FieldMaskedModel::InaccessibleError)
        expect(a.class_b).to be_a ClassB
        expect { a.class_b.id }.to raise_error(FieldMaskedModel::InaccessibleError)
        expect(a.class_b.type).to eq "Power"
        expect { a.class_c_list }.to raise_error(FieldMaskedModel::InaccessibleError)
      end
    end

    context "when many values are specified as field_mask" do
      it "creates a model object" do
        f = Google::Protobuf::FieldMask.new(paths: [
          "id",
          "name",
          "class_b.id",
          "class_b.type",
          "class_c_list.id",
          "class_c_list.role",
        ])
        m = TestMsg::ClassA.new({
          id: 1,
          name: "Taro",
          class_b: {
            id: 2,
            type: "Power",
          },
          class_c_list: [
            {
              id: 1,
              role: "Specialist",
            }
          ]
        })
        a = ClassA.new(field_mask: f, message: m)
        expect(a.id).to eq 1
        expect(a.name).to eq "Taro"
        expect(a.class_b).to be_a ClassB
        expect(a.class_b.id).to eq 2
        expect(a.class_b.type).to eq "Power"
        expect(a.class_c_list).to be_a Array
        expect(a.class_c_list.size).to eq 1
        expect(a.class_c_list.first).to be_a ClassC
        expect(a.class_c_list.first.id).to eq 1
        expect(a.class_c_list.first.role).to eq "Specialist"
      end
    end

    context "when nil is set" do
      it "creates a model object with nil attributes" do
        f = Google::Protobuf::FieldMask.new(paths: [
          "class_b.id",
          "class_b.type",
        ])
        m = TestMsg::ClassA.new({
          class_b: nil,
        })
        a = ClassA.new(field_mask: f, message: m)
        expect(a.class_b).to eq nil
      end
    end

    context "when blank array is set" do
      it "creates a model object with blank array attributes" do
        f = Google::Protobuf::FieldMask.new(paths: [
          "class_c_list.id",
          "class_c_list.role",
        ])
        m = TestMsg::ClassA.new({
          class_c_list: [],
        })
        a = ClassA.new(field_mask: f, message: m)
        expect(a.class_c_list).to eq []
      end
    end

    context "when timestamp is set" do
      it "creates a model object with Time attributes" do
        f = Google::Protobuf::FieldMask.new(paths: [
          "created_at",
        ])
        m = TestMsg::ClassA.new({
          created_at: Google::Protobuf::Timestamp.new(seconds: Time.new(2019, 3, 1).to_i)
        })
        a = ClassA.new(field_mask: f, message: m)
        expect(a.created_at).to eq Time.new(2019, 3, 1)
      end
    end
  end

  describe "#to_h" do
    it "returns a Hash object" do
      f = Google::Protobuf::FieldMask.new(paths: [
        "id",
        "name",
        "class_b.id",
        "class_b.type",
        "class_c_list.id",
        "class_c_list.role",
      ])
      m = TestMsg::ClassA.new({
        id: 1,
        name: "Taro",
        class_b: {
          id: 2,
          type: "Power",
        },
        class_c_list: [
          {
            id: 1,
            role: "Specialist",
          }
        ]
      })
      a = ClassA.new(field_mask: f, message: m)

      expect(a.to_h).to eq({
        id: 1,
        name: "Taro",
        class_b: {
          id: 2,
          type: "Power"
        },
        class_c_list: [
          { id: 1, role: "Specialist" }
        ],
      })
    end
  end

  describe "#inspect" do
    it "returns string" do
      f = Google::Protobuf::FieldMask.new(paths: [
        "id",
        "name",
        "class_b.id",
        "class_b.type",
        "class_c_list.id",
        "class_c_list.role",
      ])
      m = TestMsg::ClassA.new({
        id: 1,
        name: "Taro",
        class_b: {
          id: 2,
          type: "Power",
        },
        class_c_list: [
          {
            id: 1,
            role: "Specialist",
          }
        ]
      })
      a = ClassA.new(field_mask: f, message: m)

      result = <<~INSPECT
        <ClassA
         id: 1,
         name: "Taro",
         created_at: -,
         class_b: ClassB,
         class_c_list: [ClassC]>
      INSPECT

      expect(a.inspect).to eq result.gsub(/\n$/, '')
    end
  end

  describe ".set_inaccessible_error_callback" do
    let(:custom_error_class) {
      Class.new(StandardError)
    }
    before do
      stub_const("CustomErrorClass", custom_error_class)
    end

    it "can set custom error handler" do
      class ClassA
        set_inaccessible_error_callback -> (field) {
          raise CustomErrorClass.new("Custom error! #{field} is inaccessible")
        }
      end

      a = ClassA.new(field_mask: Google::Protobuf::FieldMask.new, message: TestMsg::ClassA.new)
      expect { a.id }.to raise_error(CustomErrorClass)
    end
  end

  describe ".fields" do
    it "returns an Array object" do
      expect(ClassA.fields).to eq [
        :id,
        :name,
        :created_at,
        {
          class_b: [
            :id,
            :type
          ],
          class_c_list: [
            :id,
            :role,
            {
              class_d_list: [
                :id,
                :not_model
              ]
            }
          ]
        }
      ]
    end
  end
end
