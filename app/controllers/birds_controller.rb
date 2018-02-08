class BirdsController < ApplicationController

    # [Create]RUD
    get '/birds/new' do
        @session = session

        erb :'/birds/new'
    end

    post '/birds' do
        # Add warning if params[:date] != session[:date] && session[:date] exists
        ## create report here and assign to bander
        session[:date] = set_date(params[:date])
        report = Report.find_by(:date => date_string) || report = Report.create(:date => date_string)
        #report.bander = current_bander
        #report.save
        @session = session
        @date_string = date_string
        params[:bird][:number_banded].to_i.times do
            @bird = Bird.new(:banding_date => params[:date])
            if find_species
                # @bird.bander = session[:bander_id]
                @bird.species = find_species
            else 
                # do you want to add this species?
                # redirect to '/species/new'
                species = Species.new(params[:bird][:species])
                species.code = species.code.upcase
                if species.save
                    @bird.species = species
                else 
                    ## THROW ERROR MESSAGE
                    redirect to '/birds/new'
                end
            end
            @bird.save
        end
        redirect to "/birds/#{slugify_date(@session[:date])}"
    end


    # C[Read]UD - ALL BIRDS
    get '/birds/:date' do
        @session = session
        @date_slug = slugify_date(@session[:date])
        @date_string = date_string
        @count_by_species = count_by_species

        erb :'/birds/show'
    end


    #ADD NARRATIVE
    get '/birds/:date/add_narrative' do
        @session = session
        @date_string = date_string
        report = Report.find_by(:date => date_string)
        if report.content && report.content != ""
            redirect to :"/birds/#{slugify_date(session[:date])}/report"
        else
            erb :'/birds/narrative'
        end
    end


    ## ADD NARRATIVE TO REPORT
    post '/birds/:date/report' do
        report = Report.find_by(:date => date_string)
        ## THROW WARNING IF NARRATIVE ALREADY EXISTS FOR DATE
        if params[:narrative][:content] && params[:narrative][:content] != ""
            report.content = params[:narrative][:content]
            report.save
        end
        redirect to :"/birds/#{slugify_date(session[:date])}/report"
    end

    get '/birds/:date/report' do
        if params[:date] != slugify_date(session[:date])
            session[:date] = set_date(params[:date])
        end
        @session = session
        @bander ="Anthony" ## HARD CODED UNTIL IMPLEMENT BANDER LOGIN
        @narrative = Report.find_by(:date => date_string).content
        @date_string = date_string
        @date_slug = slugify_date(@session[:date])
        @count_by_species = count_by_species
        erb :'/birds/report'
    end

    # CR[Update]D
    ## THIS IS GOING TO BE UPDATING A SET OF BIRDS (FOR A GIVEN DATE) RATHER THAN AN INDIVIDUAL; 
    get '/birds/:date/edit' do
        @session = session
        @date_string = date_string
        @count_by_species = count_by_species
        @narrative = Report.find_by(:date => date_string).content
        erb :'/birds/edit'
    end

    patch '/birds' do
        if params[:narrative][:content]
            Report.find_by(:date => date_string).update(:content => params[:narrative][:content])
        end
        if params[:delete]
            params[:delete].each do | code, value |
                count_by_species.each do |species, count_from_db|
                    if species.code == code
                        count_from_db.times { delete_species(code) }
                    end
                end
            end
        end
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
                    delete_species(species.code)
                end
            end
        end
        if params[:add_more_birds]
            redirect to '/birds/new'
        else
            redirect to :"/birds/#{slugify_date(session[:date])}/report"
        end
    end


    ## SUBMIT
    post '/birds/submit' do
        report = Report.find_by(:date => date_string).update(:status => "posted")
        session.delete("date")

        redirect to :'/'
    end
    

    #  HELPERS
    helpers do
        def find_species
            Species.find_by_code(params[:bird][:species][:code])
        end

        def count_by_species
            Bird.group("species").where("banding_date = ?", date_string).count
        end

        def delete_species(code)
            species_to_delete = Species.find_by_code(code)
            bird_to_delete = Bird.find_by(:banding_date => date_string, :species_id => species_to_delete.id) 
            bird_to_delete.delete

        end

        def slugify_date(date)
            date.strftime("%b-%d").downcase
        end

        # def slugify_date_string(date_string)
        #     date_string.downcase.gsub(/\s/,"-")
        # end

        def set_date(date_string)
            year = Time.now.year
            month_string = parse_month(date_string).capitalize
            month = Date::MONTHNAMES.index(month_string) || Date::ABBR_MONTHNAMES.index(month_string)
            day = parse_day(date_string)
            Time.new(year, month, day)
        end

        def parse_month(date_string)
            month_string = date_string.gsub(/[^a-zA-Z]/, "")
        end

        def parse_day(date_string)
            str=date_string.gsub(/\s?[a-zA-Z]\s?/, "")
            str.gsub(/[-]/, "")
        end

        def date_string
            session[:date].strftime("%b %d")
        end
    end

end