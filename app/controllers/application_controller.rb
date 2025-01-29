class ApplicationController < ActionController::Base
  # Ensure only modern browsers are supported (for web-based apps)
  allow_browser versions: :modern

  # # Apply authentication for API requests
  # before_action :authenticate_request

  # def authenticate_request
  #   header = request.headers['Authorization']
  #   return render json: { error: 'Token missing' }, status: :unauthorized unless header

  #   token = header.split(' ').last
  #   decoded = JsonWebToken.decode(token)

  #   if decoded
  #     @current_user = User.find(decoded[:user_id])
  #   else
  #     render json: { error: 'Invalid token' }, status: :unauthorized
  #   end
  # end
end
