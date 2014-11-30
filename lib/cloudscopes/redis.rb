module Cloudscopes
  
  class RedisClient
    
    def initialize(host,port)
      @redis = Redis.new(host: host, port: port)
    end
    
    def resque_size(*keys)
      keys = [ keys ] unless keys.is_a? Array
      keys.collect do |key|
        @redis.llen("resque:queue:#{key}")
      end.reduce(0,:+)
    end
    
    def list_size(*keys)
      keys = [ keys ] unless keys.is_a? Array
      keys.collect do |key|
        @redis.llen("#{key}")
      end.reduce(0,:+)
    end
    
    def resques(pattern)
      @redis.smembers("resque:queues").grep(pattern)
    end
    
  end
  
  def self.redis(host = 'localhost', port = 6379)
    require 'redis'
    RedisClient.new(host,port)
  end
  
end

