# frozen_string_literal: true

class ActiveFunction
  module Functions
    module Response
      ActiveFunction.register_plugin :response, self

      class Response < Struct.new(:status, :headers, :body, :committed)
        def initialize(status: 200, headers: {}, body: nil, committed: false) = super(status, headers, body, committed)

        def to_h
          {
            statusCode: status,
            headers:,
            body:
          }
        end

        def commit!
          self.committed = true
        end

        alias_method :committed?, :committed
      end
    end
  end
end
