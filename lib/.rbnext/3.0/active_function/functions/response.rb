# frozen_string_literal: true

module ActiveFunction
  module Functions
    class Response
      attr_accessor :status, :headers, :body

      def initialize(status: 200, headers: {}, body: nil)
        @status     = status
        @headers    = headers
        @body       = body
        @committed  = false
      end

      def to_h
        {
          statusCode: status,
          headers:    headers,
          body:       body
        }
      end

      def commit!
        @committed = true
      end

      def committed? ;  @committed; end
    end
  end
end
