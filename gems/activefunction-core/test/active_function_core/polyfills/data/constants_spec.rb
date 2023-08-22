# frozen_string_literal: true

# source: https://github.com/ruby/spec/blob/master/core/data/constants_spec.rb

require_relative "../../../spec_helper"
require_relative "../../../../lib/active_function_core/polyfills/data"

# ruby_version_is ''...'3.2' do
#   describe "Data" do
#     it "does not exist anymore" do
#       Object.should_not have_constant(:Data)
#     end
#   end
# end

ruby_version_is "3.2" do
  describe "Data" do
    it "is a new constant" do
      Data.superclass.should == Object
    end

    it "is not deprecated" do
      -> { Data }.should_not complain
    end
  end
end
