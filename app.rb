require_relative "model/model.rb"
include WEBBSERVER_SLUTPROJEKT

class App < Sinatra::Base
	
	register Sinatra::Flash
	enable :sessions

	get '/' do
		result = get_articles()
		if session[:user]
			cart = get_cart(session[:user]["id"])
		end
		slim :shop, locals:{error: flash[:error], user: session[:user], articles: result, cart: cart}
	end

	get '/login' do
		cart = nil
		slim :login, locals:{error: flash[:error], user: session[:user], cart: cart}
	end

	get '/register' do
		cart = nil
		slim :register, locals:{error: flash[:error], user: session[:user], cart: cart}
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

	post '/add_to_cart' do
		article_id = params["article_id"]

		if session[:user] == nil
			flash[:error] = "You must log in to use a cart"
			redirect '/'
		else
			add_to_cart(article_id, session[:user]["id"])
			redirect '/'
		end


	end
end