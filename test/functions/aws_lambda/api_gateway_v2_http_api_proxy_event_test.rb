# frozen_string_literal: true

require "test_helper"
require "support/aws_event_helper"
require "active_function"
require "active_function/functions/aws_lambda/api_gateway_v2_http_api_proxy_event"

describe ActiveFunction::Functions::AwsLambda::ApiGatewayV2HttpApiProxyEvent do
  subject { described_class.new(**event_hash) }

  let(:described_class) { ActiveFunction::Functions::AwsLambda::ApiGatewayV2HttpApiProxyEvent }
  let(:event_hash) { load_aws_event_fixture(:api_gateway_v2_http_api_proxy) }

  it { _(described_class::Event).must_be :<, described_class::Type }
  it { _(described_class::RequestContext).must_be :<, described_class::Type }
  it { _(described_class::Authorizer).must_be :<, described_class::Type }
  it { _(described_class::JwtAuthorizer).must_be :<, described_class::Type }
  it { _(described_class::Authentication).must_be :<, described_class::Type }
  it { _(described_class::ClientCert).must_be :<, described_class::Type }
  it { _(described_class::Validity).must_be :<, described_class::Type }
  it { _(described_class::Http).must_be :<, described_class::Type }

  it { _(subject).must_be_kind_of described_class::Event }
  it { _(subject.to_h).must_equal event_hash }

  describe ActiveFunction::Functions::AwsLambda::ApiGatewayV2HttpApiProxyEvent::Event do
    subject { described_class::Event.new(**event_hash) }

    it { _(subject).must_respond_to :version }
    it { _(subject.version).must_be_kind_of String }

    it { _(subject).must_respond_to :routeKey }
    it { _(subject.routeKey).must_be_kind_of String }

    it { _(subject).must_respond_to :rawPath }
    it { _(subject.rawPath).must_be_kind_of String }

    it { _(subject).must_respond_to :rawQueryString }
    it { _(subject.rawQueryString).must_be_kind_of String }

    it { _(subject).must_respond_to :headers }
    it { _(subject.headers).must_be_kind_of Hash }

    it { _(subject).must_respond_to :requestContext }
    it { _(subject.requestContext).must_be_kind_of described_class::RequestContext }

    it { _(subject).must_respond_to :isBase64Encoded }
    it { _(subject.isBase64Encoded).must_be_kind_of TrueClass }

    it { _(subject).must_respond_to :body }
    it { _(subject.body).must_be_kind_of String }

    it { _(subject).must_respond_to :queryStringParameters }
    it { _(subject.queryStringParameters).must_be_kind_of Hash }

    it { _(subject).must_respond_to :pathParameters }
    it { _(subject.pathParameters).must_be_kind_of Hash }

    it { _(subject).must_respond_to :stageVariables }
    it { _(subject.stageVariables).must_be_kind_of Hash }

    describe "when nullable fields are not present" do
      let(:nullable_fields) { %i[queryStringParameters pathParameters stageVariables body] }
      let(:expected_hash) { event_hash.dup.merge(nullable_fields.product([nil]).to_h) }

      before do
        nullable_fields.each { |field| event_hash.delete(field) }
      end

      it { _(subject.to_h).must_equal expected_hash }
    end
  end

  describe ActiveFunction::Functions::AwsLambda::ApiGatewayV2HttpApiProxyEvent::RequestContext do
    subject { described_class::RequestContext.new(**event_hash[:requestContext]) }

    it { _(subject).must_respond_to :accountId }
    it { _(subject.accountId).must_be_kind_of String }

    it { _(subject).must_respond_to :apiId }
    it { _(subject.apiId).must_be_kind_of String }

    it { _(subject).must_respond_to :authorizer }
    it { _(subject.authorizer).must_be_kind_of described_class::Authorizer }

    it { _(subject).must_respond_to :domainName }
    it { _(subject.domainName).must_be_kind_of String }

    it { _(subject).must_respond_to :domainPrefix }
    it { _(subject.domainPrefix).must_be_kind_of String }

    it { _(subject).must_respond_to :http }
    it { _(subject.http).must_be_kind_of described_class::Http }

    it { _(subject).must_respond_to :requestId }
    it { _(subject.requestId).must_be_kind_of String }

    it { _(subject).must_respond_to :routeKey }
    it { _(subject.routeKey).must_be_kind_of String }

    it { _(subject).must_respond_to :stage }
    it { _(subject.stage).must_be_kind_of String }

    it { _(subject).must_respond_to :time }
    it { _(subject.time).must_be_kind_of String }

    it { _(subject).must_respond_to :timeEpoch }
    it { _(subject.timeEpoch).must_be_kind_of Integer }

    describe "when nullable fields are not present" do
      let(:nullable_fields) { %i[domainPrefix authorizer authentication] }
      let(:expected_hash) { event_hash[:requestContext].dup.merge(nullable_fields.product([nil]).to_h) }

      before do
        nullable_fields.each { |field| event_hash[:requestContext].delete(field) }
      end

      it { _(subject.to_h).must_equal expected_hash }
    end
  end

  describe ActiveFunction::Functions::AwsLambda::ApiGatewayV2HttpApiProxyEvent::Authorizer do
    subject { described_class::Authorizer.new(**event_hash[:requestContext][:authorizer]) }

    it { _(subject).must_respond_to :jwt }
    it { _(subject.jwt).must_be_kind_of described_class::JwtAuthorizer }
  end

  describe ActiveFunction::Functions::AwsLambda::ApiGatewayV2HttpApiProxyEvent::JwtAuthorizer do
    subject { described_class::JwtAuthorizer.new(**event_hash[:requestContext][:authorizer][:jwt]) }

    it { _(subject).must_respond_to :claims }
    it { _(subject.claims).must_be_kind_of Hash }

    it { _(subject).must_respond_to :scopes }
    it { _(subject.scopes).must_be_kind_of Array }
  end

  describe ActiveFunction::Functions::AwsLambda::ApiGatewayV2HttpApiProxyEvent::Authentication do
    subject { described_class::Authentication.new(**event_hash[:requestContext][:authentication]) }

    it { _(subject).must_respond_to :clientCert }
    it { _(subject.clientCert).must_be_kind_of described_class::ClientCert }
  end

  describe ActiveFunction::Functions::AwsLambda::ApiGatewayV2HttpApiProxyEvent::ClientCert do
    subject { described_class::ClientCert.new(**event_hash[:requestContext][:authentication][:clientCert]) }

    it { _(subject).must_respond_to :clientCertPem }
    it { _(subject.clientCertPem).must_be_kind_of String }

    it { _(subject).must_respond_to :subjectDN }
    it { _(subject.subjectDN).must_be_kind_of String }

    it { _(subject).must_respond_to :issuerDN }
    it { _(subject.issuerDN).must_be_kind_of String }

    it { _(subject).must_respond_to :serialNumber }
    it { _(subject.serialNumber).must_be_kind_of String }

    it { _(subject).must_respond_to :validity }
    it { _(subject.validity).must_be_kind_of described_class::Validity }
  end

  describe ActiveFunction::Functions::AwsLambda::ApiGatewayV2HttpApiProxyEvent::Http do
    subject { described_class::Http.new(**event_hash[:requestContext][:http]) }

    it { _(subject).must_respond_to :method }
    it { _(subject.method).must_be_kind_of String }

    it { _(subject).must_respond_to :path }
    it { _(subject.path).must_be_kind_of String }

    it { _(subject).must_respond_to :protocol }
    it { _(subject.protocol).must_be_kind_of String }

    it { _(subject).must_respond_to :sourceIp }
    it { _(subject.sourceIp).must_be_kind_of String }

    it { _(subject).must_respond_to :userAgent }
    it { _(subject.userAgent).must_be_kind_of String }

    describe "when nullable fields are not present" do
      let(:nullable_fields) { %i[sourceIp userAgent] }
      let(:expected_hash) { event_hash[:requestContext][:http].dup.merge(nullable_fields.product([nil]).to_h) }

      before do
        nullable_fields.each { |field| event_hash[:requestContext][:http].delete(field) }
      end

      it { _(subject.to_h).must_equal expected_hash }
    end
  end
end
