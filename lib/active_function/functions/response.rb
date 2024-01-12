# frozen_string_literal: true

module ActiveFunction
  module Functions
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
