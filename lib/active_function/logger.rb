require "logger"

module ActiveFunction
  class Logger # :nodoc:
    class << self
      def error(err)
        logger.error(err)
      end
  
      def info(msg)
        logger.info(msg)
      end
  
      def logger
        @logger ||= ::Logger.new($stdout).tap do |l|
          l.level = ::Logger::INFO
          l.formatter = proc do |severity, datetime, _progname, msg|
            "#{datetime.strftime("%Y-%m-%d %H:%M:%S")} #{severity} #{msg}\n"
          end
        end
      end
  
      private_class_method :logger
    end
  end
end
