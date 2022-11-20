require "./config/boot"
require "active_function"

module Routing
  API_ACTIONS = {
    GET: :index,
    POST: :create,
    DELETE: :destroy
  }.freeze

  def route(event:, context:)
    case ActiveFunction::EventSource.call(event)
    when ActiveFunction::EventSource::API_GATEWAY_AWS_PROXY
      {action: API_ACTIONS[event["httpMethod"]], params: event["queryStringParameters"]}
    when ActiveFunction::EventSource::DYNAMO_DB
      {action: :db_event, params: event.slice(:Records)}
    else
      raise "Unavailable event source"
    end
  end
end

class TestsFunctions < ActiveFunction::Base
  include Routing

  PERMITED_PARAMS = %i[id name last_executed_at].freeze

  before_action :pre_message, only: %i[create]
  after_action :post_message, only: %i[destroy]

  def index
    render json: {params: params}, status: 200
  end

  def create
    render json: @message, status: 200
  end

  def destroy
    render json: @message, status: 200
  end

  def db_event
    render json: params.require(:Records), status: 200
  end

  private

  def pre_message
    @message = "Resource created"
  end

  def post_message
    @message = "Resource destroyed"
  end
end

event = File.read("../fixtures/aws_events/dynamodb.json")
p TestsFunctions.handler(event: event, context: nil)
