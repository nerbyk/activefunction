# frozen_string_literal: true
# # frozen_string_literal: true

# require "test_helper"

# describe ActiveFunction::Functions::Callbacks do
#   let(:described_class) { ActiveFunction::Functions::Callbacks }

#   before(:each) do
#     @test_class = Class.new do
#       include ActiveFunction::Functions::Callbacks

#       # private

#       # def test_method
#       # end

#       # def test_method2
#       # end
#     end
#   end

#   describe "#(before|after)_action" do
#     it "adds a callback" do
#       @test_class.before_action :test_method

#       assert_includes @test_class.callbacks[:before], :test_method
#     end

#     it "adds a before callback with options" do
#       @test_class.after_action :test_method, only: :index, if: :test?

#       assert_includes @test_class.callbacks[:after], :test_method
#       assert_equal({only: :index, if: :test?}, @test_class.callbacks[:after][:test_method])
#     end

#     it "adds multiple before callbacks" do
#       @test_class.before_action :test_method
#       @test_class.after_action :test_method2

#       assert_includes @test_class.callbacks[:before], :test_method
#       assert_includes @test_class.callbacks[:after], :test_method2
#     end

#     it "adds multiple before callbacks with options" do
#       @test_class.before_action :test_method, only: :index
#       @test_class.after_action :test_method2, if: :test?

#       assert_includes @test_class.callbacks[:before], :test_method
#       assert_includes @test_class.callbacks[:after], :test_method2
#       assert_equal({only: :index}, @test_class.callbacks[:before][:test_method])
#       assert_equal({if: :test?}, @test_class.callbacks[:after][:test_method2])
#     end
#   end

#   describe "#run_callbacks" do
#     it "runs the callbacks" do
#       mock = MiniTest::Mock.new
#       mock.expect :test_method, true
#       mock.expect :test_method2, true

#       @test_class.before_action :test_method
#       @test_class.after_action :test_method2
#     end
#   end
# end
