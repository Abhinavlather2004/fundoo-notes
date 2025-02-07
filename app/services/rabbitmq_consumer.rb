class RabbitMQConsumer
  def self.subscribe(queue_name)
    channel = RabbitMQ.channel
    queue = channel.queue(queue_name, durable: true)

    puts "Waiting for messages in #{queue_name}..."
    queue.subscribe(block: true) do |delivery_info, _properties, body|
      puts "Received: #{body}"
      # Process message here
    end
  end
end