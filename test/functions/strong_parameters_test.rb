# frozen_string_literal: true

require "test_helper"

class StrongParametersFunction
  include ActiveFunction::Functions::Core
  include ActiveFunction::Functions::StrongParameters
end

class StrongParametersTest < Minitest::Test
  def setup
    @function = StrongParametersFunction.new
  end

  def test_params
    assert_instance_of ActiveFunction::Functions::StrongParameters::Parameters, @function.params
  end
end

describe ActiveFunction::Functions::StrongParameters::Parameters do
  let(:described_class) { ::ActiveFunction::Functions::StrongParameters::Parameters }

  def assert_nested_params(expected, actual)
    assert_equal expected, actual.instance_variable_get(:@parameters)
  end

  describe "#[]" do
    it "returns the value of the parameter when it exists" do
      params = described_class.new({name: "Pupa"})

      assert_equal "Pupa", params[:name]
    end

    it "returns Parameter instance if the parameter is a hash" do
      params = described_class.new({user: {name: "Pupa"}})
      nested_params = params[:user]

      assert_instance_of described_class, nested_params
    end

    it "returns array of Parameter instances if the parameter is an array of hashes" do
      params = described_class.new({users: [{name: "Pupa"}, {name: "Lupa"}]})
      nested_params = params[:users]

      assert_instance_of Array, nested_params
      assert_instance_of described_class, nested_params[0]
      assert_instance_of described_class, nested_params[1]
    end

    it "returns the value of the nested parameter when it exists" do
      params = described_class.new({user: {name: "Pupa"}})

      assert_nested_params({name: "Pupa"}, params[:user])
    end

    it "returns nested parameters when they exist" do
      params = described_class.new({user: {name: "Pupa"}})
      nested_params = params[:user][:name]

      assert_equal "Pupa", nested_params
    end

    it "returns nil when the parameter does not exist" do
      params = described_class.new({})

      assert_nil params[:name]
    end

    it "returns nil when the nested parameter does not exist" do
      params = described_class.new({user: {}})

      assert_nil params[:user][:name]
    end
  end

  describe "#require" do
    it "returns the value of the parameter when it exists" do
      params = described_class.new({name: "Pupa"})

      assert_equal "Pupa", params.require(:name)
    end

    it "returns Parameter instance if the parameter is a hash" do
      params = described_class.new({user: {name: "Pupa"}})
      required_params = params.require(:user)

      assert_instance_of described_class, required_params
    end

    it "returns array of Parameter instances if the parameter is an array of hashes" do
      params = described_class.new({users: [{name: "Pupa"}, {name: "Lupa"}]})
      required_params = params.require(:users)

      assert_instance_of Array, required_params
      assert_instance_of described_class, required_params[0]
      assert_instance_of described_class, required_params[1]
    end

    it "returns the value of the nested parameter when it exists" do
      params = described_class.new({user: {name: "Pupa"}})

      assert_nested_params({name: "Pupa"}, params.require(:user))
    end

    it "returns nested parameters when they exist" do
      params = described_class.new({user: {name: "Pupa"}})
      required_params = params.require(:user).require(:name)

      assert_equal "Pupa", required_params
    end

    it "raises a ParameterMissingError when the parameter does not exist" do
      params = described_class.new({})

      assert_raises(ActiveFunction::ParameterMissingError) { params.require(:name) }
    end
  end

  describe "#permit" do
    it "returns new Parameters instance with permitted parameters" do
      params = described_class.new({id: 1, name: "Pupa"})
      permitted_params = params.permit(:id, :name)

      assert_instance_of described_class, permitted_params
      assert_equal true, permitted_params.instance_variable_get(:@permitted)
      assert_nested_params({id: 1, name: "Pupa"}, permitted_params)
    end

    it "returns new Parameters instances with permitted nested parameters" do
      params = described_class.new({user: {name: "Pupa", roles: [{id: 1, name: "Admin"}]}})
      permitted_params = params.permit(user: [:name, roles: [:id, :name]])

      assert_instance_of described_class, permitted_params
      assert_instance_of described_class, permitted_params[:user]
      assert_instance_of described_class, permitted_params[:user][:roles][0]

      assert_equal true, permitted_params.instance_variable_get(:@permitted)
      assert_equal true, permitted_params[:user].instance_variable_get(:@permitted)
      assert_equal true, permitted_params[:user][:roles][0].instance_variable_get(:@permitted)
    end

    it "returns new Parameters instance with valid values in nested parameters" do
      params = described_class.new({user: {name: "Pupa", roles: [{id: 1, name: "Admin"}]}})
      permitted_params = params.permit(user: [:name, roles: [:id, :name]])

      assert_equal "Pupa", permitted_params[:user][:name]
      assert_nested_params({id: 1, name: "Admin"}, permitted_params[:user][:roles][0])
    end

    it "ignores parameter when the it does not exist" do
      params = described_class.new({})

      assert_nested_params({}, params.permit(:name))
    end

    it "ignores nested parameter when the it does not exist" do
      params = described_class.new({user: {}})
      permitted_params = params.permit(user: [:name])

      assert_nested_params({}, permitted_params[:user])
    end
  end

  describe "#to_h" do
    it "returns hash with permitted parameters" do
      params = described_class.new({id: 1, name: "Pupa"})
      permitted_params = params.permit(:id, :name)

      assert_equal({id: 1, name: "Pupa"}, permitted_params.to_h)
    end

    it "returns hash with permitted nested parameters" do
      params = described_class.new({user: {name: "Pupa", roles: [{name: "Admin"}]}})
      permitted_params = params.permit(user: [:name, roles: [:id, :name]])

      assert_equal({user: {name: "Pupa", roles: [{name: "Admin"}]}}, permitted_params.to_h)
    end

    it "returns hash with permitted nested parameters when the parameter is an array of hashes" do
      params = described_class.new({users: [{id: 1, name: "Pupa"}, {id:2, name: "Lupa"}]})
      permitted_params = params.permit(users: [:name])

      assert_equal({users: [{name: "Pupa"}, {name: "Lupa"}]}, permitted_params.to_h)
    end

    it "returns hash with permitted nested parameters when the parameter is an array of hashes with nested parameters" do
      params = described_class.new({users: [{name: "Pupa", roles: [{id: 1, name: "Admin"}]}, {name: "Lupa", roles: [{id: 2, name: "User"}]}]})
      permitted_params = params.permit(users: [:name, roles: [:name]])

      assert_equal({users: [{name: "Pupa", roles: [{name: "Admin"}]}, {name: "Lupa", roles: [{name: "User"}]}]}, permitted_params.to_h)
    end

    # test UnpermittedParameterError case when the parameter is an array of hashes with nested parameters
    it "raises UnpermittedParameterError when some parameter is not permitted" do
      params = described_class.new({name: "Pupa"})

      assert_raises(ActiveFunction::UnpermittedParameterError) { params.to_h }
    end
  end
end
