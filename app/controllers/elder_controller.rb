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
    name = params[:name]
    serial_number = params[:serial_number] || ''
    address = params[:address]
    token  = encrypt_token(phone)

    if !user_exists?(phone) && Elder.new(phone: phone, pwd: pwd, public_key: token, name: name, serial_number: serial_number, address: address).save
      elder = Elder.find_by_phone(phone)
      render json: {message: 'Sign up successfully', token: token, id: elder.id, name: elder.name, phone: elder.phone, serial_number: elder.serial_number}, status: :created
    else
      render text: 'Already exists', status: :unprocessable_entity
    end
  end

  def update
    params.require(:user).permit!
    token = request.headers[:Authorization]
    elder_id = params[:user][:id]
    if auth?(token, elder_id)
      elder = Elder.find_by_id(params[:user][:id])
      elder.update_attributes!(params[:user])
      render json: {message: 'Update successfully',
                    token: elder.public_key,
                    id: elder.id,
                    name: elder.name,
                    phone: elder.phone,
                    serial_number: elder.serial_number}, status: :ok
    else
      unauthorized_action
    end
  end

  private

  def auth?(token, elder_id)
    Elder.find_by(id: elder_id, public_key: token)
  end

  def unauthorized_action
    render text: 'Authentication failed', status: :unauthorized
  end
  def encrypt_token(phone)
    rsa_private = OpenSSL::PKey::RSA.generate 2048
    payload = {:phone => phone}
    JWT.encode payload, rsa_private, 'RS256'
  end

  def user_exists?(phone)
    Elder.find_by(phone: phone)
  end


end