# frozen_string_literal: true

module ActiveFunction
  module Functions
    module AwsLambda
      if RUBY_VERSION < "3.2"
        raise LoadError, <<~ERROR
          Error: Unsupported Ruby version detected. AWS Lambda currently supports only Ruby 3.2.
          For seamless integration, ensure your Ruby runtime version is up-to-date.
          Explore AWS Lambda documentation for more details: 
          
          https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html
        ERROR
      end

      ActiveFunction.register_plugin :aws_lambda, self
    end
  end
end
