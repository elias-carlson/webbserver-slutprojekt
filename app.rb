require_relative "model/model.rb"
include WEBBSERVER_SLUTPROJEKT

class App < Sinatra::Base
	
	register Sinatra::Flash
	enable :sessions

	get '/' do
		slim :index		
	end

	get '/login' do
		slim :login
	end

	get '/register' do
		slim :register
	end

	post '/register' do
		username = params["username"]
		password = params["password"]
		confirm_password = params["confirm_password"]

		if password == confirm_password
			create_user(username, password)
			redirect('/login')
		else
			flash[:error] = "Passwords don't match."
		end
	end

	post '/login' do
		username = params["username"]
		password = params["password"]

		user = get_user(username)

		if user == nil
			flash[:error] = "No user found with that username."
		end

		password_digest = user["password"]

		if password_digest == password
			session[:user] = true
			redirect('/')
		else
			flash[:error] = "Incorrect username or password."
			redirect('/login')
		end
	end
end