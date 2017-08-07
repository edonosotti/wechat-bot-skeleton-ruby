require 'dotenv'
require 'sinatra'

require_relative './lib/db/redismanager'
require_relative './lib/wechat/wechatapiresource'
# require_relative './lib/wechat/wechatqueueprocessor'

$ROOT_PATH = File.dirname(__FILE__)

# Load .env files for local development (DO NOT push it to production!)
Dotenv.load("#{$ROOT_PATH}/../.env")

# Create a DatabaseManager instance
db_manager = RedisManager.new(ENV['REDIS_URL'])

# Map routes (see: http://www.sinatrarb.com/intro.html#Routes)
get '/wechat' do
  resource = WeChatApiResource.new(db_manager, ENV['WECHAT_TOKEN'])
  return resource.get(request, params)
end

post '/wechat' do
  resource = WeChatApiResource.new(db_manager, ENV['WECHAT_TOKEN'])
  resource.post(request, params)
end
