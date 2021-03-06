class SessionsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    get '/home' do
        if Helpers.is_logged_in?(session)
            if params[:save_draft]
                session.delete(:date)
            end
            @reports = Report.where("bander_id = ? AND status = ?", session[:bander_id], "draft").sort_by {|r| Date.parse(r.date)}.reverse
            @bander = Helpers.current_bander(session)
            erb :'/sessions/logged_in'
        else
            redirect to '/login'
        end

    end

    get '/login' do
        if Helpers.is_logged_in?(session)
            redirect to '/home'
        else
            erb :'sessions/login'
        end
    end

    post '/sessions' do
        @bander = Bander.find_by(name: params[:username].capitalize) 
        if @bander && @bander.authenticate(params[:password])
            session[:bander_id] = @bander.id
            flash[:message].clear if flash[:message]
            redirect to '/home'
        elsif params[:username] == "" || params[:password] == ""
                flash[:message] = "Please enter your name and password"
        elsif @bander = Bander.find_by(name: params[:username].capitalize)
            flash[:message] = "Invalid login information"
        else
            flash[:message] = "No account exists under that name"
        end
        session[:temp]={}
        session[:temp][:entered_name] = params[:username]
        # erb :'sessions/login' ## DOING IT THIS WAY RETAINS FLASH MESSAGE
        redirect to '/login' ## DOING IT THIS WAY BREAKS THE FLASH MESSAGE
        end
    

    delete '/logout' do 
        session.clear
        redirect to '/'
    end
        
    
end