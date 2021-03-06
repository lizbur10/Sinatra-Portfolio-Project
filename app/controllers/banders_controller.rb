class BandersController < ApplicationController
    require 'rack-flash'
    use Rack::Flash
    
    # [Create]RUD
    get '/banders/new' do
        erb :'/banders/new'
    end

    post '/banders' do
        if params[:bander][:name] == "" || params[:bander][:password] == "" || params[:bander][:email] == ""
            flash[:message] = "Error: all fields required. Please enter your name, email and password."
        elsif !Helpers.validate_email(params[:bander][:email])
            flash[:message] = "Please enter a valid email address."
        elsif bander_exists
            flash[:message] = "Error: there is already an account under that name or email address."
        else
            bander = Bander.new(params[:bander])
            bander.name = bander.name.titleize
            bander.email = bander.email.downcase
            bander.save
            session[:bander_id] = bander.id
            # redirect to :"/banders/#{bander.slug}"
            session.delete(:temp)
            redirect to :'/home'
        end
        session[:temp]={}
        session[:temp][:entered_name] = params[:bander][:name]
        session[:temp][:entered_email] = params[:bander][:email]
        redirect to '/banders/new'
    end

    # C[Read]UD - ALL BANDERS
    get '/banders' do
        if Helpers.is_logged_in?(session)
            @banders = Bander.all
            erb :'banders/index'
        else
            redirect to '/login'
        end
    end

    # C[Read]UD - SPECIFIC BANDER
    get '/banders/:slug' do
        if Helpers.is_logged_in?(session)
            @bander = find_bander
            @session = session
            erb :"banders/show"
        else
            redirect to '/login'
        end
    end

    # CR[Update]D 
    get '/banders/:slug/edit' do
        if Helpers.is_logged_in?(session)        
            @bander = find_bander
            if @bander.id == session[:bander_id]
                erb :'/banders/edit'
            else
                ## This is redundant - it should never fire
                flash[:message] = "You do not have permission to edit this information"
                redirect to "/banders/#{@bander.slug}"
            end
        else
            redirect to '/login'
        end
    end

    patch '/banders/:slug' do
        @bander = find_bander
        if !params[:cancel_changes]
        
            if params[:bander][:name] == ""
                flash[:message] = "Error: name cannot be blank"
            elsif params[:bander][:email] == ""
                flash[:message] = "Error: email cannot be blank"
            elsif params[:bander][:password] == ""
                flash[:message] = "Error: password cannot be blank"                
            elsif !Helpers.validate_email(params[:bander][:email])
                flash[:message] = "Please enter a valid email address."
            else
                @bander.update(params[:bander])
                session.delete(:temp)
                redirect to "/banders/#{@bander.slug}"

            end
            session[:temp]={}
            session[:temp][:entered_name] = params[:bander][:name] ##if params[:bander][:name]
            session[:temp][:entered_email] = params[:bander][:email] ##if params[:bander][:email]
            session[:temp][:entered_password] = params[:bander][:password] ##if params[:bander][:password]
            redirect to "/banders/#{@bander.slug}/edit"
        end
        session.delete(:temp) if session[:temp]
        redirect to "/banders/#{@bander.slug}"

    end

    # CRU[Delete]
    ## NOT DOING THIS - MAYBE METHOD TO DISABLE A BANDER'S LOGIN BUT RETAIN THEIR DATA


    # HELPER METHODS
    helpers do
        def find_bander
            Bander.find_by_slug(params[:slug])
        end

        def bander_exists
            Bander.find_by(:name => params[:bander][:name].titleize) || Bander.find_by(:email => params[:bander][:email].downcase)
        end
    end
end