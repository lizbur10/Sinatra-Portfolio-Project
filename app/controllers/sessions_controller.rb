class SessionsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    get '/home' do
        @reports = Report.where("bander_id = ? AND status = ?", session[:bander_id], "draft").sort_by {|r| Date.parse(r.date)}.reverse
        @bander = Helpers.current_bander(session[:bander_id])
        
        erb :'/sessions/logged_in'
    end

    get '/login' do
        if Helpers.is_logged_in?(session)
            redirect to '/home'
        else
            erb :'sessions/login'
        end
    end

    post '/sessions' do
        if @bander = Bander.find_by(name: params[:username].capitalize, password: params[:password])
            session[:bander_id] = @bander.id
            redirect to '/home'
        else
            flash[:message] = "Invalid login information"
            erb :'sessions/login'
            # redirect to '/login' ## DOING IT THIS WAY BROKE MY FLASH MESSAGE
        end
    end

    get '/logout' do 
        session.clear
        redirect to '/'
    end
        
    
end