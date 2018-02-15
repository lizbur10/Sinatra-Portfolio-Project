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
            session.delete(:entered_name)
            session.delete(:entered_email)
            redirect to :'/home'
        end
        session[:entered_name] = params[:bander][:name]
        session[:entered_email] = params[:bander][:email]
        redirect to '/banders/new'
    end

    # C[Read]UD - ALL BANDERS
    get '/banders' do
        @banders = Bander.all
        erb :'banders/index'
    end

    # C[Read]UD - SPECIFIC BANDER
    get '/banders/:slug' do
        @bander = find_bander
        @session = session
        erb :"banders/show"
    end

    # CR[Update]D 
    get '/banders/:slug/edit' do
        @bander = find_bander
        if @bander.id == session[:bander_id]
            erb :'/banders/edit'
        else
            ## This is redundant - it should never fire
            flash[:message] = "You do not have permission to edit this information"
            redirect to "/banders/#{@bander.slug}"
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
                redirect to "/banders/#{@bander.slug}"

            end
        end
        redirect to "/banders/#{params[:slug]}"
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