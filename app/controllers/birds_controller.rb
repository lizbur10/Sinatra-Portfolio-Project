class BirdsController < ApplicationController

    # [Create]RUD
    get '/birds/new' do
        @session = session

        erb :'/birds/new'
    end

    post '/birds' do
        session[:date] = set_date(params[:date]) if !session[:date]
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
        @date = params[:date]
        #
        @session = session
        @count_by_species = Bird.group("species").where("banding_date = ?", @date).count

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

        def set_date(date_string)
            year = Time.now.year
            month_string = parse_month(date_string)
            month = Date::MONTHNAMES.index(month_string) || Date::ABBR_MONTHNAMES.index(month_string)
            day = parse_day(date_string)
            Time.new(year, month, day)
        end

        def parse_month(date_string)
            month_string = date_string.gsub(/[^a-zA-Z]/, "")
        end

        def parse_day(date_string)
            date_string.gsub(/\s?[a-zA-Z]\s?/, "")
        end
    end

end