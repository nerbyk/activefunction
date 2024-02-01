# frozen_string_literal: true

require "active_function_core/plugins/types"

module ActiveFunction::Functions::AwsLambda
  class DynamoDBEvent
    include ActiveFunctionCore::Plugins::Types

    define_schema do
      type Event => {
        Records: Array[Record]
      }

      type Record => {
        eventID:        String,
        eventVersion:   String,
        eventName:      String,
        eventSource:    String,
        eventSourceARN: String,
        awsRegion:      String,
        dynamodb:       StreamRecord
      }

      type StreamRecord => {
        Keys:           Hash[Symbol, AttributeValue],
        SequenceNumber: String,
        SizeBytes:      Integer,
        StreamViewType: String,
        "?NewImage":    Hash[Symbol, AttributeValue],
        "?OldImage":    Hash[Symbol, AttributeValue]
      }

      type AttributeValue => {
        "?B":    String,
        "?BOOL": Boolean,
        "?BS":   Array[String],
        "?L":    Array[AttributeValue],
        "?M":    Hash[Symbol, AttributeValue],
        "?N":    String,
        "?NS":   Array[String],
        "?NULL": Boolean,
        "?S":    String,
        "?SS":   Array[String]
      }
    end
  end
end
