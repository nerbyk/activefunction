# frozen_string_literal: true

if RUBY_VERSION < "3.2"
  raise <<~ERROR
    Error: Unsupported Ruby version detected. AWS Lambda currently supports only Ruby 3.2.
    For seamless integration, ensure your Ruby runtime version is up-to-date.
    Explore AWS Lambda documentation for more details: 
    
    https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html
  ERROR
end

module ActiveFunction
  module Functions
    module AwsLambda
      ActiveFunction.register_plugin :aws_lambda, self
    end
  end
end
