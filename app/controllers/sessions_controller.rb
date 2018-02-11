class SessionsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    get '/home' do
        @reports = Report.where("bander_id = ? AND status = ?", session[:bander_id], "draft").order(date: :desc)
        @bander = Helpers.current_bander(session[:bander_id])
        
        erb :'/sessions/logged_in'
    end

    get '/sessions/login' do

        if Helpers.is_logged_in?(session)
            redirect to '/home'
        else
            binding.pry
            erb :'sessions/login'
        end
    end

    post '/sessions' do
        if @bander = Bander.find_by(name: params[:username].capitalize, password: params[:password])
            session[:bander_id] = @bander.id
            redirect '/home'
        else
            flash[:message] = "Invalid login information"
            redirect '/sessions/login'
        end
    end

    get '/sessions/logout' do 
        session.clear
        redirect '/'
    end
        
    
end