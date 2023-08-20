# frozen_string_literal: true

require "active_function"

function = Class.new(ActiveFunction::Controller::Base) do
  before_action :action, only: :index, if: :condition?
  after_action :action, only: :index, if: :condition?

  def index
    permitted_params = params.require(:bodt).permit(:name, :id)
    render json: permitted_params, status: 200
  end

  private

  def condition?
    true
  end
end

function.process(:index, request: {body: {name: "John", id: 1}})
