class SessionsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    get '/home' do
        @reports = Report.where("bander_id = ?", session[:bander_id]).order(date: :desc)
        @bander = Helpers.current_bander(session[:bander_id])
        
        erb :'/sessions/logged_in'
    end

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