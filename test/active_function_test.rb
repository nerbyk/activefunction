# frozen_string_literal: true

# # frozen_string_literal: true

require "test_helper"
require "mocha/minitest"
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

# rubocop:enable Lint/ConstantDefinitionInBlock
