require "./config/boot"

class TestsFunctions < ActiveFunction::Functions
  @@tests = []
  Test = Struct.new("Test", :id, :name, :last_executed_at)

  PERMITED_PARAMS = %i[
    id
    name
    last_executed_at
  ]

  before_action :tests_params, only: %i[get create]
  before_action
  # after_action

  def get
    render json: @@tests.find { |t| t.id == tests_params[:id] }, status: 200
  end

  def create
    test = Test.new(*tests_params.values)

    @@tests.push test

    render :json, test

  rescue => err
    render json: err, status: 500
  end

  def destroy
    @@tests.delete_if { |t| t.id == test_params[:id] }

    render json: 'ok', status: 200
  end

  private

  def tests_params
    params.require(:data).permit(:id, :name, :last_executed_at)
  end
end
