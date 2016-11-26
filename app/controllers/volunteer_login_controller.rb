class VolunteerLoginController < ApplicationController
  def login
    phone = params[:phone]
    pwd = params[:pwd]

    volunteer = Volunteer.find_by(phone: phone)

    if volunteer && pwd === volunteer.pwd
      rsa_private, rsa_public = encrypt_token
      volunteer.public_key = rsa_public

      if volunteer.save
        payload = {:phone => phone, :pwd => pwd}
        token = JWT.encode payload, rsa_private, 'RS256'

        render json: {message: 'Login successfully', token: token}, status: :ok
      else
        render text: 'Login failed', status: :unauthorized
      end
    else
      render text: 'Login failed', status: :unauthorized
    end
  end

  def sign_up
    rsa_private,rsa_public = encrypt_token

    phone = params[:phone]
    pwd = params[:pwd]

    if !user_exists?(phone) && Volunteer.new(phone: phone, pwd: pwd, public_key: rsa_public).save
      payload = {:phone => phone, :pwd => pwd}
      token = JWT.encode payload, rsa_private, 'RS256'

      render json: {message: 'Sign up successfully', token: token}, status: :created
    else
      render text: 'Already exists', status: :unprocessable_entity
    end
    # decoded_token = JWT.decode token, rsa_public, true, { :algorithm => 'RS256' }
  end

  private
  def encrypt_token
    rsa_private = OpenSSL::PKey::RSA.generate 2048
    rsa_public = rsa_private.public_key

    return rsa_private, rsa_public
  end

  def user_exists?(phone)
    Volunteer.find_by(phone: phone)
  end
end