require "logger"
require 'ostruct'

module Kopilka
  module Logger
    def error(err)
      logger.error(err)
    end 

    def info(err)
      logger.info(err)
    end 

    def logger
      $logger ||= LoggerBuilder.new # :rubocop:disable Style/GlobalVars
    end

    module_function :logger

    class LoggerBuilder
      DEFAULT_OPTIONS = {
        level: ::Logger::INFO,
        formatter: ->(severity, datetime, progname, msg) {
          "#{datetime.strftime("%Y-%m-%d %H:%M:%S")} #{severity} #{msg}\n"
        }
      }.freeze

      def initialize(options = {})
        @options = DEFAULT_OPTIONS if options.empty?
        build
      end

      private

      attr_reader :options

      def build
        ::Logger.new($stdout).tap do |logger|
          logger.level = options[:level]
          logger.formatter = options[:formatter]
        end
      end
    end
  end
end
