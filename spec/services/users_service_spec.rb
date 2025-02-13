require 'rails_helper'

RSpec.describe UsersService, type: :service do
  let(:user) { create(:user, email: 'test@example.com', password: 'Password@123', mobile_number: '+91-9876543210') }

  describe '.create_user' do
    context 'with valid parameters' do
      it 'creates a user successfully' do
        params = { name: 'John Doe', email: 'john@example.com', password: 'Password@123', mobile_number: '+91-9876543210' }
        result = UsersService.create_user(params)

        expect(result[:success]).to be true
        expect(result[:user]).to have_attributes(
          name: 'John Doe',
          email: 'john@example.com',
          mobile_number: '+91-9876543210'
        )
      end
    end

    context 'with duplicate email' do
      it 'fails to create a user' do
        create(:user, email: 'john@example.com')

        params = { name: 'John Doe', email: 'john@example.com', password: 'Password@123', mobile_number: '+91-9876543222' }
        result = UsersService.create_user(params)

        expect(result[:success]).to be false
        expect(result[:errors]).to have_key(:email)
      end
    end
  end

  describe '.authenticate_user' do
    context 'with valid credentials' do
      it 'returns a valid token' do
        params = { email: user.email, password: 'Password@123' }
        result = UsersService.authenticate_user(params)

        expect(result[:success]).to be true
        expect(result[:token]).to be_present
      end
    end

    context 'with invalid email' do
      it 'raises an InvalidEmailError' do
        params = { email: 'wrong@example.com', password: 'Password@123' }

        expect { UsersService.authenticate_user(params) }.to raise_error(UsersService::InvalidEmailError, 'Invalid email')
      end
    end

    context 'with incorrect password' do
      it 'raises an InvalidPasswordError' do
        params = { email: user.email, password: 'WrongPassword' }

        expect { UsersService.authenticate_user(params) }.to raise_error(UsersService::InvalidPasswordError, 'Invalid password')
      end
    end
  end

  describe '.forgot_password' do
    context 'when email exists' do
      before do
        allow(UsersService).to receive(:generate_otp).and_return(123456)
      end

      it 'generates and sends an OTP' do
        result = UsersService.forgot_password(user.email)

        expect(result[:success]).to be true
        expect(result[:message]).to eq('OTP sent successfully')
      end
    end

    context 'when email does not exist' do
      it 'returns an error' do
        result = UsersService.forgot_password('nonexistent@example.com')

        expect(result[:success]).to be false
        expect(result[:error]).to eq('User with this email does not exist')
      end
    end
  end

  describe '.reset_password' do
    context 'when OTP is correct and valid' do
      before do
        UsersService.class_variable_set(:@@otp, 123456)
        UsersService.class_variable_set(:@@otp_generated_at, Time.now)
      end

      it 'resets the password successfully' do
        params = { otp: 123456, new_password: 'NewPassword@123' }
        result = UsersService.reset_password(user.id, params)

        expect(result).to be_truthy
        expect(user.reload.authenticate('NewPassword@123')).to be_truthy
      end
    end

    context 'when OTP is incorrect' do
      before do
        UsersService.class_variable_set(:@@otp, 123456)
        UsersService.class_variable_set(:@@otp_generated_at, Time.now)
      end

      it 'raises an InvalidOtpError' do
        params = { otp: 999999, new_password: 'NewPassword@123' }

        expect { UsersService.reset_password(user.id, params) }.to raise_error(UsersService::InvalidOtpError, 'Invalid OTP')
      end
    end

    context 'when OTP is expired' do
      before do
        UsersService.class_variable_set(:@@otp, 123456)
        UsersService.class_variable_set(:@@otp_generated_at, 11.minutes.ago)
      end

      it 'raises an InvalidOtpError' do
        params = { otp: 123456, new_password: 'NewPassword@123' }

        expect { UsersService.reset_password(user.id, params) }.to raise_error(UsersService::InvalidOtpError, 'OTP has expired')
      end
    end

    context 'when OTP is not generated' do
      before do
        UsersService.class_variable_set(:@@otp, nil)
      end

      it 'raises an InvalidOtpError' do
        params = { otp: 123456, new_password: 'NewPassword@123' }

        expect { UsersService.reset_password(user.id, params) }.to raise_error(UsersService::InvalidOtpError, 'OTP has not been generated')
      end
    end
  end
end
