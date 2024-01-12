# frozen_string_literal: true

require "test_helper"
require "mocha/minitest"

require "active_function/functions/rendering"

describe ActiveFunction::Functions::Rendering do
  let(:described_class) { ActiveFunction::Functions::Rendering }
  let(:klass) do
    Class.new { include ActiveFunction::Functions::Rendering }
  end
  let(:response_mock) { Struct.new(:status, :headers, :body) }

  subject { klass.new }

  it { _(subject).must_respond_to :render }

  describe "#render" do
    let(:instance) { klass.new }
    let(:performed) { false }
    let(:res) { response_mock.new }

    subject { instance.instance_variable_get(:@response) }

    before do
      instance.instance_variable_set(:@response, res)
      instance.expects(:performed?).returns(performed)
    end

    describe "when response is not committed" do
      before do
        res.expects(:commit!).once
      end

      it "should change response status" do
        instance.render status: 201

        _(subject.status).must_equal 201
      end

      it "should change response headers" do
        instance.render head: {"X-Test" => "test"}

        _(subject.headers).must_equal({"X-Test" => "test", "Content-Type" => "application/json"})
      end

      it "should change response body" do
        instance.render json: "test"

        _(subject.body).must_equal "test".to_json
      end

      it "should change response status, headers and body" do
        instance.render status: 412, head: {"X-Test" => "test"}, json: {a: 1, b: 2}

        _(subject.to_h).must_equal({status: 412, headers: {"X-Test" => "test", "Content-Type" => "application/json"}, body: {a: 1, b: 2}.to_json})
      end
    end

    describe "when response is already committed" do
      let(:performed) { true }

      before do
        res.expects(:commit!).never
      end

      it "should raise double render error" do
        assert_raises(described_class::DoubleRenderError) do
          instance.render
        end
      end
    end
  end
end
