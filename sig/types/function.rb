require "active_function"

ROUTES = {
  /GET/  => :index,
  /POST/ => :db_event
}.freeze

module RBS; end

class RBS::Function < ActiveFunction::Base
  def route = ROUTES.fetch event[:requestContext][:http][:method]

  before_action :before_action, only: :index
  after_action :after_action, if: :after_action?
  after_action :after_action2

  def index
    params.permit(:awslogs, :aws).require(:awslogs)
    render json: params.permit(:awslogs, :aa), status: 200
  end

  def db_event
    params.require(:Records).each do |record|
      record.permit(:dynamodb).require(:NewImage).permit(:id, :name, :last_executed_at).to_h
    end
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
