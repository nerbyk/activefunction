# frozen_string_literal: true

module ActiveFunction
  module Functions
    module AwsLambda
      ActiveFunction.register_plugin :aws_lambda, self
    end
  end
end
