class ElderController < ApplicationController
  def login
    phone = params[:phone_number]
    pwd = params[:password]

    elder = Elder.find_by(phone: phone)

    if elder && pwd === elder.pwd
      token = encrypt_token(phone)
      elder.public_key = token

      if elder.save
        render json: {message: 'Login successfully', token: token, id: elder.id, name: elder.name, phone: elder.phone, serial_number: elder.serial_number}, status: :ok
      else
        render text: 'Login failed', status: :unauthorized
      end
    else
      render text: 'Login failed', status: :unauthorized
    end
  end

  def sign_up
    phone = params[:phone_number]
    pwd = params[:password]
    serial_number = params[:serial_number] || ''
    address = params[:address]
    token  = encrypt_token(phone)

    if !user_exists?(phone) && Elder.new(phone: phone, pwd: pwd, public_key: token, serial_number: serial_number, address: address).save
      elder = Elder.find_by_phone(phone)
      render json: {message: 'Sign up successfully', token: token, id: elder.id, name: elder.name, phone: elder.phone, serial_number: elder.serial_number}, status: :created
    else
      render text: 'Already exists', status: :unprocessable_entity
    end
  end

  private

  def encrypt_token(phone)
    rsa_private = OpenSSL::PKey::RSA.generate 2048
    payload = {:phone => phone}
    JWT.encode payload, rsa_private, 'RS256'
  end

  def user_exists?(phone)
    Elder.find_by(phone: phone)
  end


end