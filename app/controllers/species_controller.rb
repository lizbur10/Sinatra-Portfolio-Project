class SpeciesController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    # [Create]RUD
    get '/species/new' do

        erb :'/species/new'
    end

    post '/species' do
        ## VALIDATIONS
        if !Helpers.validate_alpha_code(params[:species][:code])
            flash[:message] = "Please enter a valid four-letter alpha code."
        elsif Species.find_by(:name => params[:species][:name].titleize) && Species.find_by(:name => params[:species][:name].titleize) == Species.find_by(:code => params[:species][:code].upcase) 
            flash[:message] = "This species already exists in the database."
        elsif params[:species][:name] == ""
            flash[:message] = "Please enter both the species name and the alpha code."
        elsif Species.find_by(:name => params[:species][:name].titleize)
            flash[:message] = "There is already a species in the database with this name; please verify the alpha code"
        elsif Species.find_by(:code => params[:species][:code].upcase)
            flash[:message] = "There is already a species in the database with this alpha code; please verify the species name"
        ## END VALIDATIONS
        else
            Helpers.create_species(params[:species])
            flash[:message] = "Species successfully added"        
            redirect to '/species'
        end
        redirect to '/species/new'
    end

    # C[Read]UD - ALL SPECIES
    get '/species' do
        @all_species = Species.all
        erb :'/species/index'
    end

    # C[Read]UD - SPECIFIC SPECIES
    get '/species/:code' do
        @species = find_species_by_code
        erb :'/species/show'
    end

    # CR[Update]D
    get '/species/:code/edit' do
        @species = find_species_by_code
        erb :'/species/edit'
    end

    patch '/species/:id' do
        @species = Species.find(params[:id]) ## NEED TO IMPLEMENT 'OLD_CODES' FUNCTIONALITY
        if !params[:cancel_changes]
            @species.update(params[:species])
            @species.code = @species.code.upcase
            @species.save
        end
        redirect to "/species/#{@species.code}"
    end

    #CRU[Delete]
    ## NOT GOING TO DO THIS - WILL INSTEAD IMPLEMENT A CHECK WHEN BANDER TRIES TO ADD A NEW SPECIES

    # HELPER METHODS
    helpers do
        def find_species_by_code
            Species.find_by_code(params[:code])
        end
    end

end