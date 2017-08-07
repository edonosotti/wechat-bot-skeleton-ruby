require 'digest/sha1'

require_relative './wechatmessageformatter'

# Adapted from: https://gist.github.com/edonosotti/7d990ad93fb3eaca5cae9df0af5600e2
# See: http://www.sinatrarb.com/intro.html
class WeChatApiResource
  def initialize(db_manager, token)
    @db_manager = db_manager
    @token = token
  end

  # The WeChat server will issue a GET request in order to verify the chatbot backend server upon configuration.
  # See: http://admin.wechat.com/wiki/index.php?title=Getting_Started#Step_2._Verify_validity_of_the_URL
  # and: http://admin.wechat.com/wiki/index.php?title=Message_Authentication
  def get(request, params)
    # Get the parameters from the query string
    signature = params['signature'] || ''
    timestamp = params['timestamp'] || ''
    nonce = params['nonce'] || ''
    echostr = params['echostr'] || ''

    # Compute the signature (note that the shared token is used too)
    verification_elements = [@token, timestamp, nonce]
    verification_elements = verification_elements.sort
    verification_string = verification_elements.join('')
    verification_string = Digest::SHA1.hexdigest(verification_string)

    # If the signature is correct, output the same "echostr" provided by the WeChat server as a parameter
    if signature == verification_string
      return echostr
    end

    return ''
  end

  # Messages will be POSTed from the WeChat server to the chatbot backend server,
  # see: http://admin.wechat.com/wiki/index.php?title=Common_Messages
  def post(request, params)
    formatter = WeChatMessageFormatter.new
    message = formatter.parse_incoming_message(request.body.read.to_s)
    # Parse the WeChat message XML format

    if message['valid']
      # Queue the message for delayed processing
      @db_manager.store_message(message)

      # WeChat always requires incoming user messages to be acknowledged at
      # least with an empty string (empty strings are not shown to users),
      # see: https://chatbotsmagazine.com/building-chatbots-for-wechat-part-1-dba8f160349
      # In this sample app, we simulate a "Customer Service"-like scenario
      # providing an instant reply to the user, announcing that a complete
      # reply will follow.
      reply = "Thank you for your message. We will get back to you as soon as possible!"
      return formatter.format_instant_reply(message, reply)
    end

    return 'Message was sent in a wrong format.'
  end
end
