require "./config/boot"
require "active_function"

module Routing
  API_ACTIONS = {
    "GET"    => :index,
    "POST"   => :create,
    "DELETE" => :destroy
  }.freeze

  def route
    case ActiveFunction::EventSource.call(event)
    when ActiveFunction::EventSource::API_GATEWAY_HTTP then API_ACTIONS[event[:httpMethod]]
    when ActiveFunction::EventSource::DYNAMO_DB then :db_event
    else
      raise "Unavailable event source"
    end
  end
end

class TestsFunctions < ActiveFunction::Base
  include Routing

  PERMITED_PARAMS = %i[id name last_executed_at].freeze

  before_action :pre_message, if: :if_action, only: [:index]
  after_action :post_message, only: %i[destroy]

  def index
    binding.irb
    render json: {params: params }, status: 200
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

  def if_action
    false
  end
end

# dynamodb_event = File.read("../fixtures/aws_events/dynamodb.json")
api_gateway_http_event = File.read("../fixtures/aws_events/dynamodb.json")
p TestsFunctions.handler(event: api_gateway_http_event, context: nil)
