# frozen_string_literal: true

# # frozen_string_literal: true

require "test_helper"
require "mocha/minitest"

fork do
  require "active_function"

  describe ActiveFunction do
    subject { ActiveFunction }

    it { _(subject).must_respond_to :config }
    it { _(subject).must_respond_to :plugins }
    it { _(subject).must_respond_to :plugin }

    fork do
      describe ".config" do
        subject { ActiveFunction.config(&config_proc) }

        let(:config_proc) { proc { plugin :callbacks } }

        it "should class_eval yield & freeze" do
          ActiveFunction.expects(:plugin).with(:callbacks)

          subject

          _(ActiveFunction.plugins).must_be :frozen?
          _(ActiveFunction::Base).must_be :frozen?
        end
      end
    end

    fork do
      ActiveFunction.config { plugin :callbacks }

      describe ".plugin" do
        it "should plugin ActiveFunction::Base with provided plugin" do
          _(ActiveFunction::Base).must_include ActiveFunction::Functions::Callbacks
        end

        it "should raise error when plugin is not registered" do
          assert_raises ArgumentError do
            ActiveFunction.config { plugin :test }
          end
        end

        it "should not allow to register plugin outside of config" do
          assert_raises RuntimeError do
            ActiveFunction.plugin :callbacks
          end
        end
      end
    end
  end
end

fork do
  require "active_function"

  class Function < ActiveFunction::Base
    def index
      @response.body = @request
    end
  end

  class ActiveFunctionTest < Minitest::Test
    def test_default_function_processing
      response = Function.process(:index, {a: 1, b: 2})

      assert_equal response, {
        statusCode: 200,
        body:       {a: 1, b: 2},
        headers:    {}
      }
    end
  end
end

fork do
  require "active_function"

  ActiveFunction.config do
    plugin :callbacks
  end

  class FunctionWithCallbacks < ActiveFunction::Base
    before_action :set_first

    def index
      @response.body = {first: @first}
    end

    private

    def set_first
      @first = 1
    end
  end

  class ActiveFunctionTest2 < Minitest::Test
    def test_function_processing_with_callbacks
      response = FunctionWithCallbacks.process(:index, {})

      assert_equal(response, {
        statusCode: 200,
        body:       {first: 1},
        headers:    {}
      })
    end

    def test_function_processing_with_inheritted_callbacks
      response = Class.new(FunctionWithCallbacks).process(:index, {})

      assert_equal(response, {
        statusCode: 200,
        body:       {first: 1},
        headers:    {}
      })
    end
  end
end

fork do
  require "active_function"

  ActiveFunction.config do
    plugin :strong_parameters
  end

  class TestFunctionWithParameters < ActiveFunction::Base
    def index
      @response.body = params
        .require(:data)
        .permit(:id, message: %i[text])
        .to_h
    end
  end

  class ActiveFunctionTest3 < Minitest::Test
    def test_function_processing_with_params
      data = {data: {id: 1, name: "Pupa", message: {id: 1, text: "test"}}}

      response = TestFunctionWithParameters.process(:index, data)

      assert_equal(response, {
        statusCode: 200,
        body:       {id: 1, message: {text: "test"}},
        headers:    {}
      })
    end
  end
end

fork do
  require "active_function"

  ActiveFunction.config do
    plugin :rendering
  end

  class FunctionWithRendering < ActiveFunction::Base
    def index
      render json: {a: 1, b: 2}, status: 201, head: {"X-Test" => "test"}
    end
  end

  class ActiveFunctionTest4 < Minitest::Test
    def test_function_processing_with_rendering
      response = FunctionWithRendering.process(:index, {})

      assert_equal(response, {
        statusCode: 201,
        body:       {a: 1, b: 2}.to_json,
        headers:    {"X-Test" => "test", "Content-Type" => "application/json"}
      })
    end
  end
end

fork do
  require "active_function"

  ActiveFunction.config do
    plugin :rendering
    plugin :callbacks
    plugin :strong_parameters
  end

  class FunctionWithAllPlugins < ActiveFunction::Base
    before_action :load_user

    def index
      render json: @user
    end

    private

    def load_user
      @user = params
        .require(:data)
        .permit(:id, message: %i[text])
        .to_h
    end
  end

  class ActiveFunctionTest5 < Minitest::Test
    def test_function_processing_with_all_plugins
      data = {data: {id: 1, name: "Pupa", message: {id: 1, text: "test"}}}

      response = FunctionWithAllPlugins.process(:index, data)

      assert_equal(response, {
        statusCode: 200,
        body:       {id: 1, message: {text: "test"}}.to_json,
        headers:    {"Content-Type" => "application/json"}
      })
    end
  end
end
