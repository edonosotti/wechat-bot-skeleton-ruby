require 'digest/sha1'

require_relative '../../spec_helper'
require_relative '../../../src/lib/wechat/wechatapiresource'
require_relative '../../../src/lib/interfaces/idatabasemanager'

class DummyDatabaseManager
  include IDatabaseManager

  def initialize(database_url)
    true
  end

  def store_message(message)
    true
  end

  def fetch_queued_message
    true
  end
end

class DummyRequest
  attr_reader :body

  class DummyRequestBody
    def initialize(content)
      @content = content
    end

    def read
      return @content
    end
  end

  def initialize(body)
    @body = DummyRequestBody.new(body)
  end
end

describe WeChatApiResource do
  before do
    @test_db_manager = DummyDatabaseManager.new('')

    @test_token = 'TEST_WECHAT_TOKEN'

    @test_message = %(
        <xml>
        <ToUserName><![CDATA[toUser]]></ToUserName>
        <FromUserName><![CDATA[fromUser]]></FromUserName>
        <CreateTime>1348831860</CreateTime>
        <MsgType><![CDATA[text]]></MsgType>
        <Content><![CDATA[this is a test]]></Content>
        <MsgId>1234567890123456</MsgId>
        </xml>
    )

    timestamp = Time.now.to_i.to_s
    nonce = 'TEST_NONCE'
    verification_elements = [@test_token, timestamp, nonce]
    verification_elements = verification_elements.sort
    verification_string = verification_elements.join('')
    signature = Digest::SHA1.hexdigest(verification_string)
    @test_verification_data = {
      'signature' => signature,
      'timestamp' => timestamp,
      'nonce' => nonce,
      'echostr' => 'TEST_ECHOSTR'
    }

    @resource = WeChatApiResource.new(@test_db_manager, @test_token)
  end

  describe "#get" do
    context "when the server receives a valid webhook verification request" do
      it "returns the same echostr it was provided with" do
        expect { @get_result = @resource.get(nil, @test_verification_data) }.to_not raise_exception
        expect(@get_result).to eql(@test_verification_data['echostr'])
      end
    end

    context "when the server receives an invalid webhook verification request" do
      it "returns an empty string" do
        broken_verification_data = @test_verification_data
        broken_verification_data['nonce'] = 'BROKEN_NONCE'
        expect { @get_result = @resource.get(nil, broken_verification_data) }.to_not raise_exception
        expect(@get_result).to eql('')
      end
    end
  end

  describe "#post" do
    context "when the server receives a valid message" do
      it "returns a confirmation message" do
        expect { @post_result = @resource.post(DummyRequest.new(@test_message), nil) }.to_not raise_exception
        expect(@post_result).to match('<xml>')
      end
    end

    context "when the server receives an invalid message" do
      it "returns an error message" do
        expect { @post_result = @resource.post(DummyRequest.new('BROKEN_MESSAGE'), nil) }.to_not raise_exception
        expect(@post_result).not_to match('<xml>')
      end
    end
  end
end
