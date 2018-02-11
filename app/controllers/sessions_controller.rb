class SessionsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    get '/sessions/login' do
        erb :'sessions/login'
    end

    post '/sessions' do
        if @bander = Bander.find_by(name: params[:username].capitalize, password: params[:password])
            session[:bander_id] = @bander.id
            redirect '/reports'
        else
            flash[:message] = "Invalid login information"
            binding.pry
            redirect '/sessions/login'
        end
    end

    get '/sessions/logout' do 
        session.clear
        redirect '/'
    end
        
    
end