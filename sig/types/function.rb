# frozen_string_literal: true

require "active_function"

ROUTES = {
  /GET/  => :index,
  /POST/ => :db_event
}.freeze

module RBS; end

class RBS::Function < ActiveFunction::Base
  def route = ROUTES.fetch(event[:requestContext][:http][:method])

  before_action :before_action, only: :index
  after_action :after_action, if: :after_action?
  after_action :after_action2

  def index
    params.permit(:awslogs, :aws).require(:awslogs)
    render json: params.permit(:awslogs, :aa), status: 200
  end

  def db_event
    ids = params
      .require(:Records)
      .map { |r| r.require(:dynamodb).require(:Keys).permit(Id: :N).to_h }

    render json: ids, status: 200
  end

  private

  def before_action
    puts "Testing type generation for before_action"
  end

  def after_action
    puts "Testing type generation for after_action"
  end

  def after_action?
    true
  end

  def after_action2
    puts "Testing type generation for after_action2"
  end
end
