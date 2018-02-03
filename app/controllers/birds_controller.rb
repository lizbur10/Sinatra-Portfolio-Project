class BirdsController < ApplicationController

    # [Create]RUD
    get '/birds/new' do

        erb :'/birds/new'
    end

    post '/birds' do
        params[:bird][:number_banded].to_i.times do
            @session = session
            @session[:date] = params[:date]
            @bird = Bird.new(:banding_date => params[:date])
            if find_species
                # @bird.bander = session[:bander_id]
                @bird.species = find_species
            else 
                @species = Species.new(params[:bird])
                # do you want to add this species?
                #redirect to '/species/new'
            end
            @bird.save
        end
        redirect to '/birds'
    end


    # C[Read]UD - ALL BIRDS
    get '/birds' do
        @birds=Bird.all.find_all { |bird| bird.banding_date == session[:date] }
        binding.pry
        ## BY DATE
        erb :'/birds/index'
    end

    # C[Read]UD - SPECIFIC BIRDS
    # N/A


    # CR[Update]D
    ## THIS IS GOING TO BE UPDATING A SET OF BIRDS (FOR A GIVEN DATE) RATHER THAN AN INDIVIDUAL; 
    get '/birds/:date/edit' do

        erb :'/birds/edit'
    end

    patch '/birds/:id' do

    end

    #  HELPERS
    helpers do
        def find_species
            Species.find_by_code(params[:bird][:code])
        end
    end

end