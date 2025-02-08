# # If you don’t need direct Redis calls (REDIS.get, REDIS.set), delete redis.rb.
# # If you're using Sidekiq or manual Redis operations, keep it.


require 'redis'

# Redis client initialization
REDIS = Redis.new(url: "redis://localhost:6379/1")

 
# You can also check if REDIS is initialized by running
Rails.logger.info "Redis Initialized: #{REDIS.inspect}"

# class RedisWithLogging
# def initialize
#   @redis = Redis.new(url: "redis://localhost:6379/1")
# end

# def set(key, value)
#   Rails.logger.warn "🚨 REDIS SET: #{key} = #{value} (Called from: #{caller[1]})"
#   @redis.set(key, value)
# end

# def get(key)
#   value = @redis.get(key)
#   Rails.logger.warn "🔍 REDIS GET: #{key} = #{value} (Called from: #{caller[1]})"
#   value
# end

# def del(key)
#   Rails.logger.warn "🧹 REDIS DELETE: #{key} (Called from: #{caller[1]})"
#   @redis.del(key)
# end

# def method_missing(method, *args, &block)
#   @redis.send(method, *args, &block)
# end
# end

# REDIS = RedisWithLogging.new
