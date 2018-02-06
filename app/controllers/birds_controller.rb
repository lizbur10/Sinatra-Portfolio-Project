class BirdsController < ApplicationController

    # [Create]RUD
    get '/birds/new' do
        @session = session

        erb :'/birds/new'
    end

    post '/birds' do
        # Add warning if params[:date] != session[:date] && session[:date] exists
        session[:date] = set_date(params[:date])
        @session = session
        @date_string = date_string
        params[:bird][:number_banded].to_i.times do
            @bird = Bird.new(:banding_date => params[:date])
            if find_species
                # @bird.bander = session[:bander_id]
                @bird.species = find_species
            else 
                ## SPECIES DOESN'T NEED TO BE INSTANCE VAR
                # do you want to add this species?
                # redirect to '/species/new'
                @species = Species.new(params[:bird][:species])
                @species.code = @species.code.upcase
                @species.save
                @bird.species = @species
            end
            @bird.save
        end
        redirect to "/birds/#{date_slug(@session[:date])}"
    end


    # C[Read]UD - ALL BIRDS
    get '/birds/:date' do
        @session = session
        @date_slug = date_slug(@session[:date])
        @date_string = date_string
        @count_by_species = count_by_species

        erb :'/birds/show'
    end


    #ADD NARRATIVE FUNCTION
    get '/birds/:date/add_narrative' do
        @session = session
        @date_string = date_string
        erb :'/birds/add_narrative'
    end

    ## GENERATE REPORT FUNCTION
    post '/birds/:date/report' do
        @session = session
        @count_by_species = count_by_species
        ## THROW WARNING IF NARRATIVE ALREADY EXISTS FOR DATE
        narrative=Narrative.create(:content => params[:narrative][:content], :date => params[:date])
        redirect to :"/birds/#{date_slug(@session[:date])}/report"
    end

    get '/birds/:date/report' do
        @session = session
        @bander ="David" ## HARD CODED UNTIL IMPLEMENT BANDER LOGIN
        @narrative = Narrative.find_by(:date => date_string)
        @date_string = date_string
        @count_by_species = count_by_species
        erb :'/birds/report'
    end

    # CR[Update]D
    ## THIS IS GOING TO BE UPDATING A SET OF BIRDS (FOR A GIVEN DATE) RATHER THAN AN INDIVIDUAL; 
    get '/birds/:date/edit' do
        @session = session
        @count_by_species = count_by_species
        erb :'/birds/edit'
    end

    patch '/birds' do
        count_by_species.each do |species, count_from_db|
            number_change = params[:species][species.code].to_i - count_from_db
            if number_change > 0
                number_change.times do
                    add_bird = Bird.create(:banding_date => date_string)
                    add_bird.species = Species.find_by_code(species.code)
                    add_bird.save
                end
            elsif number_change < 0
                number_change.abs.times do
                    delete_species = Species.find_by_code(species.code)
                    delete_bird = Bird.find_by(:banding_date => date_string, :species_id => delete_species.id) 
                    delete_bird.delete
                end
            end
        end
        
        redirect to :"/birds/#{date_slug(session[:date])}"
    end

    #  HELPERS
    helpers do
        def find_species
            Species.find_by_code(params[:bird][:species][:code])
        end

        def count_by_species
            Bird.group("species").where("banding_date = ?", date_string).count
        end

        def date_slug(date)
            date.strftime("%b-%d").downcase
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

        def date_string
            session[:date].strftime("%b %d")
        end
    end

end