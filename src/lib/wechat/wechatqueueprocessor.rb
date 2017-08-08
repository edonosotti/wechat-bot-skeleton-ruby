require 'net/http'
require 'uri'
require 'json'

require_relative '../logging'
require_relative 'wechatmessageformatter'

class WeChatQueueProcessor
  include Logging
  attr_accessor :wechat_url

  def initialize(app_id, app_secret)
    @wechat_url = "https://api.wechat.com/cgi-bin"
    @app_id = app_id
    @app_secret = app_secret
  end

  def post_request(url, body=nil, content_type=nil)
    begin
      uri = URI.parse(url)
      client = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = body if body
      request["Content-Type"] = content_type if content_type
      response = client.request(request)
      return true, response
    rescue Exception => e
      return false, e
    end
  end

  # See: http://admin.wechat.com/wiki/index.php?title=Access_token
  def create_access_token
    url = [
      "#{@wechat_url}/token",
      "?grant_type=client_credential",
      "&appid=#{@app_id}",
      "&secret=#{@app_secret}",
    ].join('')

    token_info = nil
    response_body = nil

    success, response = post_request(url)

    if success
      response_body = response.body
      token_info = JSON.parse(response_body)
    else
      logger.error("Could not get access token from server: #{response}")
    end

    if token_info != nil && !token_info.has_key?('errcode')
      return token_info['access_token']
    else
      logger.error("Error getting WeChat access token: #{response_body}")
    end

    return nil
  end

  # See: http://admin.wechat.com/wiki/index.php?title=Customer_Service_Messages
  def process_message(message)
    access_token = create_access_token

    result = nil
    response_body = nil

    if access_token
      url = "#{@wechat_url}/message/custom/send?access_token=#{access_token}"
      response_message = "Your request: \"#{message['content']}\" has been processed, thank you!"
      formatter = WeChatMessageFormatter.new
      request_body = formatter.format_delayed_reply(message, response_message)

      success, response = post_request(url, request_body)

      if success
        response_body = response.body
        result = JSON.parse(response_body)

        return true if result && result.has_key?('errcode') && result['errcode'] == 0
      end
    end

    logger.error("Error sending Customer Service type message: #{response_body}")
    return false
  end
end
