class UserMailer < ApplicationMailer
  default from: "latherabhinav55@gmail.com"

  def text_mail(email, otp)
    @otp = otp  # ✅ Store OTP in instance variable so it can be used in the email template
    mail(to: email, subject: "Fundoo Notes - Password Reset OTP")
  end
  
  
end