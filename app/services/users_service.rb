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
    { success: true, token: token, user: {name: user.name, email: user.email} }
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
    user = User.find_by(email: email)
    return { success: false, error: "User not found" } unless user
  
    otp = rand(100000..999999) # Generate 6-digit OTP
    Rails.cache.write("reset_password_otp_#{user.id}", otp, expires_in: 10.minutes) # Store OTP in cache for 10 minutes
  
    # Send OTP to user's email
    UserMailer.text_mail(user.email, "Your OTP for password reset is #{otp}").deliver_now
  
    { success: true, message: "OTP sent to your email.", user_id: user.id }
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
  def self.reset_password(user_id, otp, new_password)
    stored_otp = Rails.cache.read("reset_password_otp_#{user_id}") # Retrieve OTP from cache
  
    return { success: false, error: "Invalid or expired OTP" } unless stored_otp && stored_otp.to_s == otp.to_s
  
    user = User.find_by(id: user_id)
    return { success: false, error: "User not found" } unless user
  
    user.update(password: new_password) # Update password
  
    Rails.cache.delete("reset_password_otp_#{user_id}") # Clear OTP after successful password reset
  
    { success: true, message: "Password has been reset successfully." }
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
    otp = rand(100000..999999)
    @otp_generated_at = Time.current
    otp
  end

  def self.valid_otp?(input_otp)
    return false if @otp.nil? || @otp_generated_at.nil?

    time_difference = Time.current - @otp_generated_at
    input_otp == @otp && time_difference < 5.minutes
  end

end