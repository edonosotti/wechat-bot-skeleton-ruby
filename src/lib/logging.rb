require 'logger'

# Taken from: https://stackoverflow.com/questions/917566/ruby-share-logger-instance-among-module-classes
module Logging
  def logger
    Logging.logger
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
