class BandersController < ApplicationController

    # [Create]RUD
    get '/banders/new' do

        erb :'/banders/new'
    end

    post '/banders' do
        # CHECK THAT NAME/EMAIL ARE NOT TAKEN
        # VALIDATE EMAIL ADDRESS
        # VALIDATE PASSWORD?
        bander = Bander.new(params[:bander])
        if bander.save
            redirect to '/banders'
        else
            #flash message here - email or name missing
            erb :'/banders/new'
        end
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
        binding.pry
        @bander = find_bander
        @bander.update(params[:bander])
        redirect to "/banders/#{@bander.slug}"
    end

    # CRU[Delete]
    ## NOT DOING THIS - MAYBE METHOD TO DISABLE A BANDER'S LOGIN BUT RETAIN THEIR DATA


    # HELPER METHODS
    helpers do
        def find_bander
            Bander.find_by_slug(params[:slug])
        end
    end
end