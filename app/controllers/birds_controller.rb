class BirdsController < ApplicationController

    # [Create]RUD
    get '/birds/new' do

        erb :'/birds/new'
    end

    post '/birds' do
        binding.pry
        redirect to '/birds'
    end


    # C[Read]UD - ALL BIRDS
    get '/birds' do
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

end