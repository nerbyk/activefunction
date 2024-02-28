# frozen_string_literal: true

require "test_helper"
require "support/aws_event_helper"
require "active_function"
require "active_function/functions/aws_lambda/dynamodb_event"

describe ActiveFunction::Functions::AwsLambda::DynamoDBEvent do
  subject { described_class.new(event_hash) }

  let(:described_class) { ActiveFunction::Functions::AwsLambda::DynamoDBEvent }
  let(:event_hash) { load_aws_event_fixture(:dynamodb) }

  it { _(subject).must_be_kind_of described_class::Event }

  it { _(subject).must_respond_to :Records }
  it { _(subject.Records).must_be_kind_of Array }
  it { _(subject.Records.first).must_be_kind_of described_class::Record }

  describe "Record" do
    subject { described_class.new(event_hash).Records[0] }

    it { _(subject).must_be_kind_of described_class::Record }

    it { _(subject).must_respond_to :eventID }
    it { _(subject.eventID).must_be_kind_of String }

    it { _(subject).must_respond_to :eventVersion }
    it { _(subject.eventVersion).must_be_kind_of String }

    it { _(subject).must_respond_to :eventName }
    it { _(subject.eventName).must_be_kind_of String }

    it { _(subject).must_respond_to :eventSource }
    it { _(subject.eventSource).must_be_kind_of String }

    it { _(subject).must_respond_to :eventSourceARN }
    it { _(subject.eventSourceARN).must_be_kind_of String }

    it { _(subject).must_respond_to :awsRegion }
    it { _(subject.awsRegion).must_be_kind_of String }

    it { _(subject).must_respond_to :dynamodb }
    it { _(subject.dynamodb).must_be_kind_of described_class::StreamRecord }
  end

  describe "Record" do
    subject { described_class::Record.new(**record_hash) }
    let(:record_hash) { event_hash[:Records][0] }

    it { _(subject).must_be_kind_of described_class::Record }

    it { _(subject).must_respond_to :eventID }
    it { _(subject.eventID).must_be_kind_of String }

    it { _(subject).must_respond_to :eventVersion }
    it { _(subject.eventVersion).must_be_kind_of String }

    it { _(subject).must_respond_to :eventName }
    it { _(subject.eventName).must_be_kind_of String }

    it { _(subject).must_respond_to :eventSource }
    it { _(subject.eventSource).must_be_kind_of String }

    it { _(subject).must_respond_to :eventSourceARN }
    it { _(subject.eventSourceARN).must_be_kind_of String }

    it { _(subject).must_respond_to :awsRegion }
    it { _(subject.awsRegion).must_be_kind_of String }

    it { _(subject).must_respond_to :dynamodb }
    it { _(subject.dynamodb).must_be_kind_of described_class::StreamRecord }
  end

  describe "StreamRecord" do
    subject { described_class::StreamRecord.new(**stream_record_hash) }
    let(:stream_record_hash) { event_hash[:Records][0][:dynamodb] }

    it { _(subject).must_be_kind_of described_class::StreamRecord }

    it { _(subject).must_respond_to :Keys }
    it { _(subject.Keys).must_be_kind_of Hash }
    it { _(subject.Keys.keys.first).must_be_kind_of Symbol }
    it { _(subject.Keys.values.first).must_be_kind_of described_class::AttributeValue }

    it { _(subject).must_respond_to :SequenceNumber }
    it { _(subject.SequenceNumber).must_be_kind_of String }

    it { _(subject).must_respond_to :SizeBytes }
    it { _(subject.SizeBytes).must_be_kind_of Integer }

    it { _(subject).must_respond_to :StreamViewType }
    it { _(subject.StreamViewType).must_be_kind_of String }

    it { _(subject).must_respond_to :NewImage }
    it { _(subject.NewImage).must_be_kind_of Hash }
    it { _(subject.NewImage.keys.first).must_be_kind_of Symbol }
    it { _(subject.NewImage.values.first).must_be_kind_of described_class::AttributeValue }

    it { _(subject).must_respond_to :OldImage }
    it { _(subject.OldImage).must_be_kind_of Hash }
    it { _(subject.OldImage.keys.first).must_be_kind_of Symbol }
    it { _(subject.OldImage.values.first).must_be_kind_of described_class::AttributeValue }

    describe "when nullable attribute is missing" do
      before do
        stream_record_hash.delete(:OldImage)
      end

      it { _(subject.OldImage).must_be_nil }
    end
  end

  describe "AttributeValue" do
    subject { described_class::AttributeValue.new(**attribute_value_hash) }
    let(:attribute_value_hash) { event_hash[:Records][0][:dynamodb][:OldImage][:Message] }

    it { _(subject).must_be_kind_of described_class::AttributeValue }

    it { _(subject).must_respond_to :S }
    it { _(subject.S).must_be_kind_of String }

    it { _(subject).must_respond_to :N }
    it { _(subject.N).must_be_nil }

    it { _(subject).must_respond_to :B }
    it { _(subject.B).must_be_nil }

    it { _(subject).must_respond_to :SS }
    it { _(subject.SS).must_be_nil }

    it { _(subject).must_respond_to :NS }
    it { _(subject.NS).must_be_nil }

    it { _(subject).must_respond_to :BS }
    it { _(subject.BS).must_be_nil }

    it { _(subject).must_respond_to :M }
    it { _(subject.M).must_be_nil }

    it { _(subject).must_respond_to :L }
    it { _(subject.L).must_be_nil }
  end
end
