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

  it "correctly implements its interface" do
    expect(@message_formatter).to respond_to(:parse_incoming_message).with(1).argument
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
end
