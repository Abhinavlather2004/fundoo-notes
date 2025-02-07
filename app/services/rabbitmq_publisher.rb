require 'bunny'

class RabbitMQProducer
  def self.publish(queue, message)
    connection = Bunny.new
    connection.start

    channel = connection.create_channel
    queue = channel.queue(queue)

    queue.publish(message.to_json, persistent: true)
    connection.close
  end
end