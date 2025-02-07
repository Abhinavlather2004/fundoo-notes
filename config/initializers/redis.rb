# If you don’t need direct Redis calls (REDIS.get, REDIS.set), delete redis.rb.
# If you're using Sidekiq or manual Redis operations, keep it.


require 'redis'

# Redis client initialization
REDIS = Redis.new(url: "redis://localhost:6379/1")

REDIS.set("test_key", "Hello from Redis!")
puts REDIS.get("test_key")  
# You can also check if REDIS is initialized by running
Rails.logger.info "Redis Initialized: #{REDIS.inspect}"