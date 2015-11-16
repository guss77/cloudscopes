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
    
    def resque_workers(queue, activity = nil)
      case activity
      when :active
        @redis.keys("resque:worker:*:#{queue}").count
      when :inactive
        resque_workers(queue, :available) - resque_workers(queue, :active)
      when :usage
        if resque_workers(queue) > 0
          resque_workers(queue, :active).to_f / resque_workers(queue)
        else
          1
        end
      else
        @redis.keys("resque:worker:*:#{queue}:started").count
      end
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

