require_relative "model/model.rb"
include WEBBSERVER_SLUTPROJEKT

class App < Sinatra::Base
	
	register Sinatra::Flash
	enable :sessions

	get '/' do
		slim :shop, locals:{error: flash[:error], user: session[:user]}
	end

	get '/login' do
		slim :login, locals:{error: flash[:error], user: session[:user]}
	end

	get '/register' do
		slim :register, locals:{error: flash[:error], user: session[:user]}
	end

	post '/register' do
		username = params["username"]
		password = params["password"]
		confirm_password = params["confirm_password"]

		user = get_user(username)

		if password == confirm_password
			if user == nil
				create_user(username, password)
				redirect('/login')
			else
				flash[:error] = "A user with this username already exists, please try again."
				redirect('/register')
			end
		else
			flash[:error] = "Passwords don't match. "
			redirect('/register')			
		end
	end

	post '/login' do
		username = params["username"]
		password = params["password"]

		user = get_user(username)

		if user == nil
			flash[:error] = "Incorrect username or password"
			redirect('/login')			
		else
			password_digest = user["password"]

			if BCrypt::Password.new(password_digest) == password
				session[:user] = user
				redirect('/')
			else
				flash[:error] = "Incorrect username or password."
				redirect('/login')
			end
		end
	end

	post '/logout' do
		session[:user] = nil
		redirect back
	end
end