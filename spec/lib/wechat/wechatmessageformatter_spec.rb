require 'nokogiri'

require_relative '../../spec_helper'
require_relative '../../../src/lib/wechat/wechatmessageformatter'

describe WeChatMessageFormatter do
  before do
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
    @message_formatter = WeChatMessageFormatter.new
  end

  describe "#incoming_message_valid?" do
    context "when a valid message is sent" do
      it "returns true" do
        @parsed_message = Nokogiri::XML(@test_message)
        expect { @validation_result = @message_formatter.incoming_message_valid?(@parsed_message) }.to_not raise_exception
        expect(@validation_result).to eql(true)
      end
    end

    context "when an invalid message is sent" do
      it "returns false" do
        @parsed_message = Nokogiri::XML(nil)
        expect { @validation_result = @message_formatter.incoming_message_valid?(@parsed_message) }.to_not raise_exception
        expect(@validation_result).to eql(false)

        @parsed_message = Nokogiri::XML('')
        expect { @validation_result = @message_formatter.incoming_message_valid?(@parsed_message) }.to_not raise_exception
        expect(@validation_result).to eql(false)

        @parsed_message = Nokogiri::XML('<xml></xml>')
        expect { @validation_result = @message_formatter.incoming_message_valid?(@parsed_message) }.to_not raise_exception
        expect(@validation_result).to eql(false)
      end
    end
  end

  describe "#parse_incoming_message" do
    context "when a valid message is sent" do
      it "parses a user message" do
        expect { @parsed_message = @message_formatter.parse_incoming_message(@test_message) }.to_not raise_exception
        expect(@parsed_message).to include('valid' => true)
      end
    end

    context "when an invalid message is sent" do
      it "handles an invalid message" do
        expect { @parsed_message = @message_formatter.parse_incoming_message(nil) }.to_not raise_exception
        expect(@parsed_message).to include('valid' => false)

        expect { @parsed_message = @message_formatter.parse_incoming_message('') }.to_not raise_exception
        expect(@parsed_message).to include('valid' => false)

        expect { @parsed_message = @message_formatter.parse_incoming_message('<xml>') }.to_not raise_exception
        expect(@parsed_message).to include('valid' => false)
      end
    end
  end

  describe "#format_instant_reply" do
    it "formats a message to a WeChat instant reply XML" do
      @parsed_message = @message_formatter.parse_incoming_message(@test_message)
      expect { @response_message = @message_formatter.format_instant_reply(@parsed_message, 'TEST_RESPONSE') }.to_not raise_exception
      @parsed_response = Nokogiri::XML(@response_message)
      expect(@parsed_response).to_not eql(nil)
      expect(@parsed_response.xpath('//Content')[0].inner_html).to eql('TEST_RESPONSE')
    end
  end

  describe "#format_delayed_reply" do
    it "formats a message to a WeChat Customer Service Message JSON" do
      @parsed_message = @message_formatter.parse_incoming_message(@test_message)
      expect { @response_message = @message_formatter.format_delayed_reply(@parsed_message, 'TEST_RESPONSE') }.to_not raise_exception
      expect(@response_message).to_not eql(nil)
      expect(@response_message['text']['content']).to eql('TEST_RESPONSE')
    end
  end
end
