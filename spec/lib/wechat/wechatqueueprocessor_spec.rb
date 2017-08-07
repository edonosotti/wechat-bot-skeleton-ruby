require_relative '../../spec_helper'
require_relative '../../../src/lib/wechat/wechatqueueprocessor'

describe WeChatQueueProcessor do
  before do
    @test_appid = "TEST_APPID"
    @test_appsecret = "TEST_APPSECRET"
    @test_base_wechat_url = "http://wechat-mock.local"
    @test_queue_processor = WeChatQueueProcessor.new(@test_appid, @test_appsecret)
    @test_queue_processor.wechat_url = @test_base_wechat_url
    @test_queued_message = { 'sender' => 'TEST_SENDER', 'content' => 'TEST_CONTENT' }
  end

  describe "#post_request" do
    context "when the server responds" do
      it "returns a valid response" do
        url = "#{@test_base_wechat_url}/test"
        stub_request(:post, url)
          .to_return(body: "OK", status: 200)
        expect { @post_result, @post_response = @test_queue_processor.post_request(url) }.to_not raise_exception
        expect(@post_result).to eql(true)
        expect(@post_response.body).to eql("OK")
      end
    end

    context "when the remote server is not responding" do
      it "returns a false value" do
        url = "#{@test_base_wechat_url}/test"
        expect { @post_result, @post_response = @test_queue_processor.post_request(url) }.to_not raise_exception
        expect(@post_result).to eql(false)
      end
    end
  end

  describe "#create_access_token" do
    context "when a valid request is issued" do
      it "returns a valid access token" do
        test_access_token = "TEST_ACCESS_TOKEN"
        stub_request(:post, "#{@test_base_wechat_url}/token?appid=#{@test_appid}&grant_type=client_credential&secret=#{@test_appsecret}")
          .to_return(body: "{\"access_token\":\"#{test_access_token}\",\"expires_in\":7200}", status: 200)
        expect { @access_token_result = @test_queue_processor.create_access_token }.to_not raise_exception
        expect(@access_token_result).to eql(test_access_token)
      end
    end

    context "when an invalid request is issued" do
      it "returns a nil value" do
        stub_request(:post, "#{@test_base_wechat_url}/token?appid=#{@test_appid}&grant_type=client_credential&secret=#{@test_appsecret}")
          .to_return(body: '{"errcode":40013,"errmsg":"invalid appid"}', status: 200)
        expect { @access_token_result = @test_queue_processor.create_access_token }.to_not raise_exception
        expect(@access_token_result).to eql(nil)
      end
    end

    context "when the remote server is not responding" do
      it "returns a nil value" do
        expect { @access_token_result = @test_queue_processor.create_access_token }.to_not raise_exception
        expect(@access_token_result).to eql(nil)
      end
    end
  end

  describe "#process_message" do
    context "when a valid request is issued" do
      it "returns true" do
        test_access_token = "TEST_ACCESS_TOKEN"
        stub_request(:post, "#{@test_base_wechat_url}/token?appid=#{@test_appid}&grant_type=client_credential&secret=#{@test_appsecret}")
          .to_return(body: "{\"access_token\":\"#{test_access_token}\",\"expires_in\":7200}", status: 200)
        stub_request(:post, "#{@test_base_wechat_url}/message/custom/send?access_token=#{test_access_token}")
          .to_return(body: "{\"errcode\":0}", status: 200)
        expect { @process_message_result = @test_queue_processor.process_message(@test_queued_message) }.to_not raise_exception
        expect(@process_message_result).to eql(true)
      end
    end

    context "when an invalid request is issued" do
      it "returns false" do
        test_access_token = "TEST_ACCESS_TOKEN"
        stub_request(:post, "#{@test_base_wechat_url}/token?appid=#{@test_appid}&grant_type=client_credential&secret=#{@test_appsecret}")
          .to_return(body: "{\"access_token\":\"#{test_access_token}\",\"expires_in\":7200}", status: 200)
        stub_request(:post, "#{@test_base_wechat_url}/message/custom/send?access_token=#{test_access_token}")
          .to_return(body: "{\"errcode\":1}", status: 200)
        expect { @process_message_result = @test_queue_processor.process_message(@test_queued_message) }.to_not raise_exception
        expect(@process_message_result).to eql(false)
      end
    end

    context "when the remote server is not responding" do
      it "returns false" do
        test_access_token = "TEST_ACCESS_TOKEN"
        stub_request(:post, "#{@test_base_wechat_url}/token?appid=#{@test_appid}&grant_type=client_credential&secret=#{@test_appsecret}")
          .to_return(body: "{\"access_token\":\"#{test_access_token}\",\"expires_in\":7200}", status: 200)
        expect { @process_message_result = @test_queue_processor.process_message(@test_queued_message) }.to_not raise_exception
        expect(@process_message_result).to eql(false)
      end
    end
  end
end
