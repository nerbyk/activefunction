require "active_function"

module RBS; end

class RBS::Function < ActiveFunction::Base
  ROUTE = {
    ActiveFunction::EventSource::CLOUD_WATCH_LOGS => :index,
    ActiveFunction::EventSource::DYNAMO_DB        => :db_event
  }

  def route
    ROUTE.dig(::ActiveFunction::EventSource.call(event))
  end

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
