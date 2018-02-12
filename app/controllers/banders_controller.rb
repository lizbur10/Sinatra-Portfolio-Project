class BandersController < ApplicationController
    require 'rack-flash'
    use Rack::Flash
    
    # [Create]RUD
    get '/banders/new' do

        erb :'/banders/new'
    end

    post '/banders' do
        # CHECK THAT NAME/EMAIL ARE NOT TAKEN
        # VALIDATE PASSWORD?
        if !Helpers.validate_email(params[:bander][:email])
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
            redirect to :'/home'
        end
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
            flash[:message] = "You do not have permission to edit this information"
            redirect to "/banders/#{@bander.slug}"
        end
    end

    patch '/banders/:slug' do
        @bander = find_bander
        if !params[:cancel_changes]
        
            if !Helpers.validate_email(params[:bander][:email])
                flash[:message] = "Please enter a valid email address."
                redirect to "/banders/#{params[:slug]}/edit"
            else
                @bander.update(params[:bander])

            end
        end
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