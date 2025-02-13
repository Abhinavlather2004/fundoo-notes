require_relative 'rabbitmq_publisher'

class UsersService

  class InvalidEmailError < StandardError
  end
  class InvalidPasswordError < StandardError
  end
  class InvalidOtpError < StandardError 
  end

  @otp = nil
  @otp_generated_at = nil

  def self.create_user(params)
    user = User.new(params)
    if user.save
      { success: true, user: user }
    else
      { success: false, errors: user.errors }
    end
  end

  def self.authenticate_user(params)
    user = User.find_by(email: params[:email])

    raise InvalidEmailError, "Invalid email" if user.nil?

    unless user.authenticate(params[:password])
      raise InvalidPasswordError, "Invalid password"
    end

    token = JsonWebToken.encode(user_id: user.id, name: user.name, email: user.email)
    { success: true, token: token }
  end

  # def self.forgot_password(email)
  #   begin
  #     user = User.find_by(email: email)
  #     raise InvalidEmailError, "User with this email does not exist" if user.nil?
  
  #     @@otp = generate_otp
  #     @@otp_generated_at = Time.current
  #     UserMailer.text_mail(user.email, @@otp).deliver_now
  
  #     { success: true, message: "OTP sent successfully" }
  #   rescue InvalidEmailError => e
  #     { success: false, error: e.message }
  #   rescue StandardError => e
  #     { success: false, error: "Something went wrong: #{e.message}" }
  #   end
  # end
  def self.forgot_password(email)
    begin
      user = User.find_by(email: email)
      raise InvalidEmailError, "User with this email does not exist" if user.nil?
  
      # Generate and save the OTP
      @@otp = generate_otp
      @@otp_generated_at = Time.current
  
      # Publish OTP to RabbitMQ
      publish_otp_to_queue(user.email, @@otp)

      OtpConsumer.start
  
      { success: true, message: "OTP sent successfully" }
    rescue InvalidEmailError => e
      { success: false, error: e.message }
    rescue StandardError => e
      { success: false, error: "Something went wrong: #{e.message}" }
    end
  end

  # def self.reset_password(user_id, rp_params)
  #   raise InvalidOtpError, "OTP has not been generated" if @@otp.nil?

  #   if rp_params[:otp].to_i == @@otp && (Time.current - @@otp_generated_at < 1.minute)
  #     user = User.find_by(id: user_id)
  #     if user
  #       user.update(password: rp_params[:new_password])
  #       @@otp = nil  # ✅ Reset OTP after successful password change
  #       return { success: true }
  #     else
  #       return { success: false, errors: "User not found" }
  #     end
  #   else
  #     return { success: false, errors: "Invalid OTP" }
  #   end
  # rescue InvalidOtpError => e
  #   { success: false, error: e.message }
  # end
  def self.reset_password(user_id, params)
    user = User.find(user_id)
  
    unless defined?(@@otp) && @@otp
      raise InvalidOtpError, 'OTP has not been generated'
    end
  
    if @@otp_generated_at < 10.minutes.ago
      raise InvalidOtpError, 'OTP has expired'
    end
  
    if params[:otp] != @@otp
      raise InvalidOtpError, 'Invalid OTP'
    end
  
    user.update!(password: params[:new_password])
    @@otp = nil # Reset OTP after successful use
    @@otp_generated_at = nil
    { success: true, message: 'Password reset successfully' }
  end


  def self.publish_otp_to_queue(email, otp)
    queue_name = "otp_email_queue"
    
    begin
      # Ensure the channel is open before publishing
      RabbitMQ.ensure_channel_open
      channel = RabbitMQ.channel
      queue = channel.queue(queue_name, durable: true)
  
      message = { email: email, otp: otp }.to_json
      queue.publish(message, persistent: true)
  
      Rails.logger.info("✅ OTP message published to RabbitMQ: #{message}")
    rescue Bunny::Exception => e
      Rails.logger.error("❌ Error publishing OTP message: #{e.message}")
      raise StandardError, "Error publishing OTP message to RabbitMQ: #{e.message}"
    end
  end

  private

  def self.generate_otp
    # rand(100000..999999) # Generates a 6-digit OTP
    @otp = rand(100000..999999)
    @otp_generated_at = Time.current
  end

  def self.valid_otp?(input_otp)
    return false if @otp.nil? || @otp_generated_at.nil?

    time_difference = Time.current - @otp_generated_at
    input_otp == @otp && time_difference < 5.minutes
  end

end