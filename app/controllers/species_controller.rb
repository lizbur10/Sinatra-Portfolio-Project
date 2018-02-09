class SpeciesController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    # [Create]RUD
    get '/species/new' do

        erb :'/species/new'
    end

    post '/species' do
        if !Helpers.validate_alpha_code(params[:species][:code])
            flash[:message] = "Please enter a valid alpha code."
            redirect to '/species/new'
        end
        species = Species.new(params[:species])
        species.code = species.code.upcase
        if species.save
            redirect to :'/species'
        else
            #flash message - both fields need to be completed
            #flash message - duplicate record found
            redirect to '/species/new'
        end
    end

    # C[Read]UD - ALL SPECIES
    get '/species' do
        @all_species = Species.all
        erb :'/species/index'
    end

    # C[Read]UD - SPECIFIC SPECIES
    get '/species/:code' do
        @species = find_species
        erb :'/species/show'
    end

    # CR[Update]D
    get '/species/:code/edit' do
        @species = find_species
        erb :'/species/edit'
    end

    patch '/species/:id' do
        @species = Species.find(params[:id]) ## NEED TO IMPLEMENT 'OLD_CODES' FUNCTIONALITY
        @species.update(params[:species])
        @species.code = @species.code.upcase
        @species.save
        redirect to "/species/#{@species.code}"
    end

    #CRU[Delete]
    ## NOT GOING TO DO THIS - WILL INSTEAD IMPLEMENT A CHECK WHEN BANDER TRIES TO ADD A NEW SPECIES

    # HELPER METHODS
    helpers do
        def find_species
            Species.find_by_code(params[:code])
        end
    end

end