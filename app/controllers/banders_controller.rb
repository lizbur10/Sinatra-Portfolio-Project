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
            session[:bander_id] = @bander.id
            redirect to :'/reports'
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
        erb :"banders/show"
    end

    # CR[Update]D 
    get '/banders/:slug/edit' do
        @bander = find_bander
        erb :'/banders/edit'
    end

    patch '/banders/:slug' do
        if !Helpers.validate_email(params[:bander][:email])
            flash[:message] = "Please enter a valid email address."
            redirect to "/banders/#{params[:slug]}/edit"
        else
            @bander = find_bander
            @bander.update(params[:bander])

            redirect to "/banders/#{@bander.slug}"
        end
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