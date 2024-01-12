# frozen_string_literal: true

require "test_helper"

describe ActiveFunction::Functions::StrongParameters do
  let(:klass) { Class.new { include ActiveFunction::Functions::StrongParameters } }
  let(:params) { {} }

  subject { klass.new }

  it { must_respond_to :params }

  describe "#params" do
    let(:described_class) { ActiveFunction::Functions::StrongParameters::Parameters }
    subject { instance.params }

    let(:instance) { klass.new }

    before do
      instance.instance_variable_set(:@request, params)
    end

    describe "#[]" do
      let(:params) { {name: "Pupa"} }

      it "should return parameter value" do
        subject[:name].must_equal "Pupa"
      end

      describe "when the parameter is an array of hashes" do
        let(:params) { {users: [{name: "Pupa"}, {name: "Lupa"}]} }

        it "should return array of Parameter instances" do
          _(subject[:users]).must_be_instance_of Array
          _(subject[:users][0]).must_be_instance_of described_class
          _(subject[:users][1]).must_be_instance_of described_class
        end
      end

      describe "when the parameter is a nested hash" do
        let(:params) { {user: {name: "Pupa"}} }

        it "should return Parameter instance" do
          _(subject[:user]).must_be_instance_of described_class
        end

        it "should return Parameters instance with valid attributes" do
          _(subject[:user].hash).must_equal(described_class.new({name: "Pupa"}).hash)
        end
      end

      describe "when the parameter or nested parameter does not exist" do
        let(:params) { {} }

        it "should return nil when the parameter does not exist" do
          _(subject[:name]).must_be_nil
        end
      end
    end

    describe "#require" do
      describe "when the parameter exists" do
        let(:params) { {name: "Pupa"} }

        it "returns the value of the parameter" do
          _(subject.require(:name)).must_equal "Pupa"
        end
      end

      describe "when the parameter is a hash" do
        let(:params) { {user: {name: "Pupa"}} }

        it "returns Parameter instance" do
          _(subject.require(:user)).must_be_instance_of described_class
        end
      end

      describe "when the parameter is an array of hashes" do
        let(:params) { {users: [{name: "Pupa"}, {name: "Lupa"}]} }

        it "returns array of Parameter instances" do
          _(subject.require(:users)).must_be_instance_of Array
          _(subject.require(:users)[0]).must_be_instance_of described_class
          _(subject.require(:users)[1]).must_be_instance_of described_class
        end
      end

      describe "when the parameter is a nested hash" do
        let(:params) { {user: {name: "Pupa"}} }

        it "returns Parameter instance" do
          _(subject.require(:user)).must_be_instance_of described_class
        end

        it "returns Parameters instance with valid attributes" do
          _(subject.require(:user).hash).must_equal(described_class.new({name: "Pupa"}).hash)
        end
      end

      describe "when the parameter or nested parameter does not exist" do
        let(:params) { {} }

        it "raises a ParameterMissingError" do
          assert_raises(described_class::ParameterMissingError) { subject.require(:name) }
        end
      end
    end
    describe "#permit" do
      describe "when there are permitted parameters" do
        let(:params) { {id: 1, name: "Pupa"} }
        let(:permitted_params) { subject.permit(:id, :name) }
        let(:permitted_params_hash) { permitted_params.send(:params) }

        it "returns new Parameters instance with permitted parameters" do
          _(permitted_params).must_be_instance_of described_class
          _(permitted_params.permitted).must_equal true
          _(permitted_params_hash).must_equal(id: 1, name: "Pupa")
        end
      end

      describe "when there are permitted nested parameters" do
        let(:params) { {user: {name: "Pupa", roles: [{id: 1, name: "Admin"}]}} }
        let(:permitted_params) { subject.permit(user: [:name, roles: [:id, :name]]) }

        it "returns new Parameters instances with permitted nested parameters" do
          _(permitted_params).must_be_instance_of described_class
          _(permitted_params[:user]).must_be_instance_of described_class
          _(permitted_params[:user][:roles][0]).must_be_instance_of described_class

          _(permitted_params.permitted).must_equal true
          _(permitted_params[:user].permitted).must_equal true
          _(permitted_params[:user][:roles][0].permitted).must_equal true
        end
      end

      describe "when there are valid values in nested parameters" do
        let(:params) { {user: {name: "Pupa", roles: [{id: 1, name: "Admin"}]}} }
        let(:permitted_params) { subject.permit(user: [:name, roles: [:id, :name]]) }
        let(:permitted_params_hash) { permitted_params[:user][:roles][0].send(:params) }

        it "returns new Parameters instance with valid values in nested parameters" do
          _(permitted_params[:user][:name]).must_equal "Pupa"
          _(permitted_params_hash).must_equal({id: 1, name: "Admin"})
        end
      end

      describe "when the parameter does not exist" do
        let(:params) { {} }
        let(:permitted_params) { subject.permit(:name) }
        let(:permitted_params_hash) { permitted_params.send(:params) }

        it "ignores parameter when it does not exist" do
          _(permitted_params_hash).must_equal({})
        end
      end

      describe "when the nested parameter does not exist" do
        let(:params) { {user: {}} }
        let(:permitted_params) { subject.permit(user: [:name]) }
        let(:permitted_params_hash) { permitted_params[:user].send(:params) }

        it "ignores nested parameter when it does not exist" do
          _(permitted_params_hash).must_equal({})
        end
      end
    end

    describe "#to_h" do
      let(:permitted_params) { subject.permit(:id, :name) }

      describe "when there are permitted parameters" do
        let(:params) { {id: 1, name: "Pupa"} }

        it "returns hash with permitted parameters" do
          _(permitted_params.to_h).must_equal({id: 1, name: "Pupa"})
        end
      end

      describe "when there are permitted nested parameters" do
        let(:params) { {user: {name: "Pupa", roles: [{name: "Admin"}]}} }
        let(:permitted_params) { subject.permit(user: [:name, roles: [:id, :name]]) }

        it "returns hash with permitted nested parameters" do
          _(permitted_params.to_h).must_equal({user: {name: "Pupa", roles: [{name: "Admin"}]}})
        end
      end

      describe "when there are permitted nested parameters and parameter is an array of hashes" do
        let(:params) { {users: [{id: 1, name: "Pupa"}, {id: 2, name: "Lupa"}]} }
        let(:permitted_params) { subject.permit(users: [:name]) }

        it "returns hash with permitted nested parameters when the parameter is an array of hashes" do
          _(permitted_params.to_h).must_equal({users: [{name: "Pupa"}, {name: "Lupa"}]})
        end
      end

      describe "when there are permitted nested parameters and parameter is an array of hashes with nested parameters" do
        let(:params) { {users: [{name: "Pupa", roles: [{id: 1, name: "Admin"}]}, {name: "Lupa", roles: [{id: 2, name: "User"}]}]} }
        let(:permitted_params) { subject.permit(users: [:name, roles: [:name]]) }

        it "returns hash with permitted nested parameters when the parameter is an array of hashes with nested parameters" do
          _(permitted_params.to_h).must_equal({
            users: [
              {name: "Pupa", roles: [{name: "Admin"}]},
              {name: "Lupa", roles: [{name: "User"}]}
            ]
          })
        end
      end

      describe "when there are unpermitted parameters" do
        let(:params) { {name: "Pupa"} }

        it "raises UnpermittedParameterError" do
          assert_raises(described_class::UnpermittedParameterError) { subject.to_h }
        end
      end
    end
  end
end
