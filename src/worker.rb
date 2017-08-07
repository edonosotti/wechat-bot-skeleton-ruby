require 'dotenv'

require_relative './lib/db/redismanager'
require_relative './lib/wechat/wechatqueueprocessor'

$ROOT_PATH = File.dirname(__FILE__)

# Load .env files for local development (DO NOT push it to production!)
Dotenv.load("#{$ROOT_PATH}/../.env")

# Create a DatabaseManager instance
db_manager = RedisManager.new(ENV['REDIS_URL'])

# Get a queued message
queued_message = db_manager.fetch_queued_message

# Process the queued message
if queued_message
  queue_processor = WeChatQueueProcessor.new(ENV['WECHAT_APPID'], ENV['WECHAT_APPSECRET'])
  queue_processor.process_message(queued_message)
end
