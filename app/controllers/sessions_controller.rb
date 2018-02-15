class SessionsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    get '/home' do
        @reports = Report.where("bander_id = ? AND status = ?", session[:bander_id], "draft").sort_by {|r| Date.parse(r.date)}.reverse
        @bander = Helpers.current_bander(session)
        
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
        elsif params[:username] == "" || params[:password] == ""
                flash[:message] = "Please enter your name and password"
        elsif @bander = Bander.find_by(name: params[:username].capitalize)
            flash[:message] = "Invalid login information"
        else
            flash[:message] = "No account exists under that name"
        end
        session[:entered_name] = params[:username]
        
        erb :'sessions/login'
        # redirect to '/login' ## DOING IT THIS WAY BROKE MY FLASH MESSAGE
        end

    get '/logout' do 
        session.clear
        redirect to '/'
    end
        
    
end