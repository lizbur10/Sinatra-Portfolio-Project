class BirdsController < ApplicationController

    # [Create]RUD
    get '/birds/new' do

        erb :'/birds/new'
    end

    post '/birds' do

        session[:date] = params[:date] if !session[:date]
        @session = session
        params[:bird][:number_banded].to_i.times do
            @bird = Bird.new(:banding_date => params[:date])
            if find_species
                # @bird.bander = session[:bander_id]
                @bird.species = find_species
            else 
                # do you want to add this species?
                #redirect to '/species/new'
                @species = Species.new(params[:bird][:species])
                @species.code = @species.code.upcase
                @species.save
                @bird.species = @species
            end
            @bird.save
        end
        redirect to "/birds/#{date_slug(params[:date])}"
    end


    # C[Read]UD - ALL BIRDS
    get '/birds/:date' do
        # @histogram = {}
        @session = session
        @count_by_species = Bird.group("species").where("banding_date = ?", @session[:date]).count
        # count_by_species.each do |key, value|
        #     @histogram[key.name] = value
        # end

        erb :'/birds/show'
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
            Species.find_by_code(params[:bird][:species][:code])
        end

        def date_slug(date)
            Helpers.slugify(date)
        end
    end

end