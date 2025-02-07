# app/workers/otp_consumer.rb
class OtpConsumer
  MAX_MESSAGES = 10 # Limit to process 10 messages

  def self.start
    channel = RabbitMQ.channel
    queue = channel.queue("otp_email_queue", durable: true)

    message_count = 0

    # Consume messages from the queue
    queue.subscribe(block: true) do |delivery_info, properties, body|
      message_count += 1

      # Stop after MAX_MESSAGES
      if message_count >= MAX_MESSAGES
        Rails.logger.info("✅ Maximum messages processed. Stopping consumer.")
        break
      end

      message = JSON.parse(body)
      email = message["email"]
      otp = message["otp"]

      Rails.logger.info("🔹 OTP for #{email}: #{otp}")

      # Send the OTP email using your mailer
      UserMailer.text_mail(email, otp).deliver_now

      Rails.logger.info("✅ OTP sent to #{email}")

      # Acknowledge the message after processing
      channel.ack(delivery_info.delivery_tag)
    end
  end
end