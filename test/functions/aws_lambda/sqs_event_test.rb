# frozen_string_literal: true

require "test_helper"
require "support/aws_event_helper"
require "active_function"
require "active_function/functions/aws_lambda/sqs_event"

describe ActiveFunction::Functions::AwsLambda::SqsEvent do
  subject { described_class.new(**event_hash) }

  let(:described_class) { ActiveFunction::Functions::AwsLambda::SqsEvent }
  let(:event_hash) { load_aws_event_fixture(:sqs) }
  let(:expected_response_hash) { load_aws_event_fixture(:sqs) }
  let(:nillable_attributes) do
    %i[AWSTraceHeader SequenceNumber MessageGroupId MessageDeduplicationId DeadLetterQueueSourceArn].product([nil]).to_h
  end

  before do
    expected_response_hash[:Records][0][:attributes].merge! nillable_attributes
  end

  it { _(subject).must_be_kind_of described_class::Event }
  it { _(subject.to_h).must_equal expected_response_hash }

  describe ActiveFunction::Functions::AwsLambda::SqsEvent::Event do
    subject { described_class::Event.new(**event_hash) }

    it { _(subject).must_respond_to :Records }
    it { _(subject.Records).must_be_kind_of Array }
    it { _(subject.Records.first).must_be_kind_of described_class::Record }
  end

  describe ActiveFunction::Functions::AwsLambda::SqsEvent::Record do
    subject { described_class::Record.new(**event_hash[:Records][0]) }

    it { _(subject).must_respond_to :messageId }
    it { _(subject.messageId).must_be_kind_of String }

    it { _(subject).must_respond_to :receiptHandle }
    it { _(subject.receiptHandle).must_be_kind_of String }

    it { _(subject).must_respond_to :body }
    it { _(subject.body).must_be_kind_of String }

    it { _(subject).must_respond_to :attributes }
    it { _(subject.attributes).must_be_kind_of described_class::RecordAttributes }

    it { _(subject).must_respond_to :messageAttributes }
    it { _(subject.messageAttributes).must_be_kind_of Hash }

    it { _(subject).must_respond_to :md5OfBody }
    it { _(subject.md5OfBody).must_be_kind_of String }

    it { _(subject).must_respond_to :eventSource }
    it { _(subject.eventSource).must_be_kind_of String }

    it { _(subject).must_respond_to :eventSourceARN }
    it { _(subject.eventSourceARN).must_be_kind_of String }

    it { _(subject).must_respond_to :awsRegion }
    it { _(subject.awsRegion).must_be_kind_of String }
  end

  describe ActiveFunction::Functions::AwsLambda::SqsEvent::RecordAttributes do
    subject { described_class.new(**event_hash).Records.first.attributes }

    it { _(subject).must_respond_to :ApproximateReceiveCount }
    it { _(subject).must_respond_to :SentTimestamp }
    it { _(subject).must_respond_to :SenderId }
    it { _(subject).must_respond_to :AWSTraceHeader }
    it { _(subject).must_respond_to :ApproximateFirstReceiveTimestamp }
    it { _(subject).must_respond_to :SequenceNumber }
    it { _(subject).must_respond_to :MessageGroupId }
    it { _(subject).must_respond_to :MessageDeduplicationId }
    it { _(subject).must_respond_to :DeadLetterQueueSourceArn }

    it { _(subject.ApproximateReceiveCount).must_be_kind_of String }
    it { _(subject.SentTimestamp).must_be_kind_of String }
    it { _(subject.SenderId).must_be_kind_of String }

    describe "Nullable fields" do
      describe "when nullable fields are present" do
        before do
          event_hash[:Records][0][:attributes].merge!(
            AWSTraceHeader:           "example_trace_header",
            SequenceNumber:           "example_sequence_number",
            MessageGroupId:           "example_message_group_id",
            MessageDeduplicationId:   "example_message_deduplication_id",
            DeadLetterQueueSourceArn: "example_dead_letter_queue_source_arn"
          )
        end

        it { _(subject.AWSTraceHeader).must_be_kind_of String }
        it { _(subject.ApproximateFirstReceiveTimestamp).must_be_kind_of String }
        it { _(subject.SequenceNumber).must_be_kind_of String }
        it { _(subject.MessageGroupId).must_be_kind_of String }
        it { _(subject.MessageDeduplicationId).must_be_kind_of String }
        it { _(subject.DeadLetterQueueSourceArn).must_be_kind_of String }
      end

      describe "when nullable fields are not present" do
        it { _(subject.AWSTraceHeader).must_be_kind_of NilClass }
        it { _(subject.SequenceNumber).must_be_kind_of NilClass }
        it { _(subject.MessageGroupId).must_be_kind_of NilClass }
        it { _(subject.MessageDeduplicationId).must_be_kind_of NilClass }
        it { _(subject.DeadLetterQueueSourceArn).must_be_kind_of NilClass }
      end
    end
  end

  describe ActiveFunction::Functions::AwsLambda::SqsEvent::MessageAttribute do
    subject { described_class.new(**event_hash).Records.first.messageAttributes[:example_attribute] }

    it { _(subject).must_respond_to :dataType }
    it { _(subject).must_respond_to :stringValue }
    it { _(subject).must_respond_to :binaryValue }
    it { _(subject).must_respond_to :stringListValues }
    it { _(subject).must_respond_to :binaryListValues }

    before do
      event_hash[:Records][0][:messageAttributes][:example_attribute] = {
        dataType: "String"
      }
    end

    describe "Nullable fields" do
      describe "when nullable fields are present" do
        before do
          event_hash[:Records][0][:messageAttributes][:example_attribute] = {
            dataType:         "String",
            stringValue:      "example_string_value",
            binaryValue:      "example_binary_value",
            stringListValues: ["example_string_list_value"],
            binaryListValues: ["example_binary_list_value"]
          }
        end

        it { _(subject.stringValue).must_be_kind_of String }
        it { _(subject.binaryValue).must_be_kind_of String }
        it { _(subject.stringListValues).must_be_kind_of Array }
        it { _(subject.binaryListValues).must_be_kind_of Array }
      end

      describe "when nullable fields are not present" do
        it { _(subject.stringValue).must_be_kind_of NilClass }
        it { _(subject.binaryValue).must_be_kind_of NilClass }
        it { _(subject.stringListValues).must_be_kind_of NilClass }
        it { _(subject.binaryListValues).must_be_kind_of NilClass }
      end
    end
  end
end
