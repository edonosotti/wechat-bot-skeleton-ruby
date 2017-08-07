require_relative '../../spec_helper'
require_relative '../../../src/lib/db/redismanager'

describe RedisManager do
  context "when a connection string is not set or wrong" do
    it "raises an exception" do
      expect { RedisManager.new() }.to raise_exception(ArgumentError)
      expect { RedisManager.new('') }.to raise_exception(ArgumentError)
      expect { RedisManager.new('INVALID URL') }.to raise_exception(URI::InvalidURIError)
    end
  end

  context "when an invalid connection string is provided" do
    before do
      @test_message = { 'name' => 'test' }
      @db_manager = RedisManager.new("redis://foo-redis-server.invalid-tld")
    end

    it "raises an exception" do
      expect { @db_manager.store_message(@test_message) }.to raise_exception(SocketError)
    end
  end

  context "when a valid connection string is provided" do
    before do
      @test_message = { 'name' => 'test' }
      @db_manager = RedisManager.new(ENV['REDIS_URL'])
    end

    it "correctly implements its interface" do
      expect(@db_manager).to respond_to(:store_message).with(1).argument
      expect(@db_manager).to respond_to(:fetch_message)
    end

    describe "#store_message" do
      it "stores a message in the queue" do
        expect { @db_manager.store_message(@test_message) }.to_not raise_exception
      end
    end

    describe "#fetch_queued_message" do
      it "fetches a stored message from the queue" do
        expect { @fetch_message_result = @db_manager.fetch_queued_message }.to_not raise_exception
        expect(@fetch_message_result).to include('name' => 'test')
      end
    end
  end
end
