require 'bunny'

module RabbitMQ
    # Connect to RabbitMQ server and keep the connection alive.
    def self.connection
      @connection ||= Bunny.new("amqp://guest:guest@localhost").tap(&:start)
    end
  
    # Ensure a valid, open channel for each message.
    def self.channel
      @channel ||= connection.create_channel
    end
  
    # Reopen the channel if it's closed or nil.
    def self.ensure_channel_open
      if @channel.nil? || @channel.closed?
        Rails.logger.info("🔹 Reopening RabbitMQ channel...")
        @channel = connection.create_channel
      end
    end
  
    # Close connection and channel when you're done.
    def self.close_channel
      @channel.close if @channel
      @connection.close if @connection
    end
  end