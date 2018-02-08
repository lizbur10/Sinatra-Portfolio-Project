class ReportsController < ApplicationController

    ## C[READ]UD - SHOW ALL REPORTS; LINK TO CREATE A NEW REPORT
    get '/reports' do
        @reports = Report.all
        erb :'/reports/index'
    end

    ## SUBMIT REPORT
    post '/reports/submit' do
        report = Report.find_by(:date => date_string).update(:status => "posted", :date_slug => Helpers.slugify_date_string(date_string))
        session.delete("date")

        redirect to :'/reports'
    end

    ## [CREATE]RUD - CREATE NARRATIVE
    get '/reports/:date/add_narrative' do
        @date_string = Helpers.date_string(session[:date])
        report = Report.find_by(:date => @date_string)
        if report.content && report.content != ""
            redirect to :"/reports/#{Helpers.slugify_date(session[:date])}"
        else
            erb :'/reports/narrative'
        end
    end

    ## [CREATE]RUD - ADD NARRATIVE TO REPORT
    post '/reports/:date' do
        @date_string = Helpers.date_string(session[:date])
        report = Report.find_by(:date => @date_string)
        ## THROW WARNING IF NARRATIVE ALREADY EXISTS FOR DATE
        if params[:narrative][:content] && params[:narrative][:content] != ""
            report.content = params[:narrative][:content]
            report.save
        end
        redirect to :"/reports/#{Helpers.slugify_date_string(report[:date])}"
    end

    ## C[READ]UD - SHOW SPECIFIC REPORT
    get '/reports/:date' do
        if !session[:date] || params[:date] != Helpers.slugify_date(session[:date])
            session[:date] = Helpers.set_date(params[:date])
        end
        @session = session
        @bander ="Anthony" ## HARD CODED UNTIL IMPLEMENT BANDER LOGIN
        @date = session[:date]
        @date_string = Helpers.date_string(@date)
        @narrative = Report.find_by(:date => @date_string).content
        @date_slug = Helpers.slugify_date(@session[:date])
        @count_by_species = Helpers.count_by_species(@date_string)
        erb :'/reports/show'
    end

    ## CR[UPDATE]D - EDIT REPORT
    get '/reports/:date/edit' do
        session[:date] = Helpers.set_date(params[:date]) if !session[:date] 
        @session = session
        @date_string = Helpers.date_string(session[:date])
        @count_by_species = Helpers.count_by_species(@date_string)
        @narrative = Report.find_by(:date => @date_string).content
        erb :'/reports/edit'
    end

    patch '/reports' do
        @date_string = Helpers.date_string(session[:date])
        if !params[:cancel_changes]
            if params[:narrative][:content]
                Report.find_by(:date => @date_string).update(:content => params[:narrative][:content])
            end
            
            Helpers.update_banding_numbers(params,@date_string)

            ## MAKE METHOD IN BIRD CLASS
            # if params[:delete]
            #     params[:delete].each do | code, value |
            #         count_by_species.each do |species, count_from_db|
            #             if species.code == code
            #                 count_from_db.times { delete_species(code) }
            #             end
            #         end
            #     end
            # end
            # count_by_species.each do |species, count_from_db|
            #     number_change = params[:species][species.code].to_i - count_from_db
            #     if number_change > 0
            #         number_change.times do
            #             add_bird = Bird.create(:banding_date => date_string)
            #             add_bird.species = Species.find_by_code(species.code)
            #             add_bird.save
            #         end
            #     elsif number_change < 0
            #         number_change.abs.times do
            #             delete_species(species.code)
            #         end
            #     end
            # end
        end
        ## END MAKE METHOD IN BIRD CLASS
        if params[:add_more_birds]
            redirect to '/birds/new'
        else
            redirect to :"/reports/#{Helpers.slugify_date(session[:date])}"
        end
    end


    helpers do
        def count_by_species
            Bird.group("species").where("banding_date = ?", date_string).count
        end

        def delete_species(code)
            species_to_delete = Species.find_by_code(code)
            bird_to_delete = Bird.find_by(:banding_date => date_string, :species_id => species_to_delete.id) 
            bird_to_delete.delete

        end


        # def set_date(date_string)
        #     year = Time.now.year
        #     month_string = parse_month(date_string).capitalize
        #     month = Date::MONTHNAMES.index(month_string) || Date::ABBR_MONTHNAMES.index(month_string)
        #     day = parse_day(date_string)
        #     Time.new(year, month, day)
        # end

        # def parse_month(date_string)
        #     month_string = date_string.gsub(/[^a-zA-Z]/, "")
        # end

        # def parse_day(date_string)
        #     str=date_string.gsub(/\s?[a-zA-Z]\s?/, "")
        #     str.gsub(/[-]/, "")
        # end

        # def date_string
        #     session[:date].strftime("%b %d")
        # end

        # def slugify_date_string(date_string)
        #     Helpers.slugify(date_string)
        #     # date_string.downcase.gsub(/\s/,"-")
        # end

        # def slugify_date(date)
        #     date.strftime("%b-%d").downcase
        # end


    end
    
end