# frozen_string_literal: true

require "json"

module AwsEventHelper
  def load_aws_event_fixture(filename)
    file_path = File.join("test", "fixtures", "aws_events", filename.to_s + "_event.json")
    JSON.parse(File.read(file_path), symbolize_names: true)
  end
end

Minitest::Test.include AwsEventHelper
