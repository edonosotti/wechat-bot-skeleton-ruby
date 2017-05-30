require 'redis'
require 'json'

require_relative '../interfaces/idatabasemanager'

class RedisManager
  include IDatabaseManager

  KEY_MESSAGE_QUEUE = 'message_queue'

  def initialize(database_url)
    @connection = Redis.new(:url => database_url)
  end

  def store_message(message)
    serialized_message = message.to_json
    @connection.rpush(RedisManager::KEY_MESSAGE_QUEUE, serialized_message)
  end

  def fetch_message
    serialized_message = @connection.lpop(RedisManager::KEY_MESSAGE_QUEUE)

    if serialized_message != nil
      return JSON.parse(serialized_message)
    end

    return nil
  end

end
