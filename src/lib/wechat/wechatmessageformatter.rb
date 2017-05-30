require 'time'
require 'nokogiri'

class WeChatMessageFormatter
  # Check if the message XML is valid, this simple bot handles TEXT messages only!
  # To learn more about the supported types of messages and how to implement them, see:
  # Common Messages: http://admin.wechat.com/wiki/index.php?title=Common_Messages
  # Event Messages: http://admin.wechat.com/wiki/index.php?title=Event-based_Messages
  # Speech Recognition Messages: http://admin.wechat.com/wiki/index.php?title=Speech_Recognition_Messages
  def incoming_message_valid?(message)
    return (
      message != nil &&
      message.xpath('//MsgType').length > 0 &&
      message.xpath('//Content').length > 0 &&
      message.xpath('//MsgType')[0].inner_html == 'text'
    )
  end

  # Parse the native WeChat message XML format to a common format
  def parse_incoming_message(message)
    parsed_message = Nokogiri::XML(message)

    if incoming_message_valid?(parsed_message)
      return {
        'sender' => parsed_message.xpath('//FromUserName')[0].inner_html,
        'receiver' => parsed_message.xpath('//ToUserName')[0].inner_html,
        'type' => parsed_message.xpath('//MsgType')[0].inner_html,
        'content' => parsed_message.xpath('//Content')[0].inner_html,
        'valid' => true
      }
    end

    return { 'valid' => false }
  end

  # Format the reply according to the WeChat XML format for synchronous replies,
  # see: http://admin.wechat.com/wiki/index.php?title=Callback_Messages
  def format_instant_reply(incoming_message, response_content)
    timestamp = Time.new.to_i
    # Sender and Receiver must be inverted in replies ;)
    return %(
      <xml>
      <ToUserName><![CDATA[#{incoming_message['sender']}]]></ToUserName>
      <FromUserName><![CDATA[#{incoming_message['receiver']}]]></FromUserName>
      <CreateTime>#{timestamp}</CreateTime>
      <MsgType><![CDATA[text]]></MsgType>
      <Content><![CDATA[#{response_content}]]></Content>
      </xml>
    )
  end
end
