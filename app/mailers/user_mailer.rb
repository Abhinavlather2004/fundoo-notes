class UserMailer < ApplicationMailer
  default from: "latheabhinav55@gmail.com"

  def text_mail(email,otp)
    @message = "Here is your One Time Password: #{otp}"
    Rails.logger.info "Sending mail to #{email}, Please wait..."
    mail(to: "ayushnagar633@gmail.com", subject: "Reset Password")
    Rails.logger.info "Sent Successfully!!"
  end
end
