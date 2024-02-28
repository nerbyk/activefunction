# frozen_string_literal: true

require "active_function_core/plugins/types"

module ActiveFunction::Functions::AwsLambda
  class SqsEvent
    include ActiveFunctionCore::Plugins::Types

    define_schema do
      type Event => {
        Records: Array[Record]
      }

      type Record => {
        messageId:         String,
        receiptHandle:     String,
        body:              String,
        attributes:        RecordAttributes,
        messageAttributes: Hash[Symbol, MessageAttribute],
        md5OfBody:         String,
        eventSource:       String,
        eventSourceARN:    String,
        awsRegion:         String
      }

      type RecordAttributes => {
        "?AWSTraceHeader":                String,
        ApproximateReceiveCount:          String,
        SentTimestamp:                    String,
        SenderId:                         String,
        ApproximateFirstReceiveTimestamp: String,
        "?SequenceNumber":                String,
        "?MessageGroupId":                String,
        "?MessageDeduplicationId":        String,
        "?DeadLetterQueueSourceArn":      String
      }

      type MessageAttribute => {
        "?stringValue":      String,
        "?binaryValue":      String,
        "?stringListValues": Array[String],
        "?binaryListValues": Array[String],
        dataType:            MessageAttributeDataType
      }

      type MessageAttributeDataType => Enum[String, Integer, Boolean]
    end
  end
end
