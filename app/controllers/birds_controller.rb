class BirdsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    # [Create]RUD
    get '/birds/new' do
        @session = session
        if !session[:date]
            if Report.all ## &CURRENT SEASON
                @date = Report.all.map{|r| Date.parse(r.date)}.max + 1.day
                @date = @date.strftime("%b %d")
            else
                @date = Time.now.strftime("%b %d") 
            end
        else
            @date = session[:date].strftime("%b %d")
        end
        erb :'/birds/new'
    end

    post '/birds' do
        params
        # Warning if params[:date] != session[:date] && session[:date] exists
        ## VALIDATIONS
        if params[:bird][:species][:code] == "" || params[:bird][:species][:name] == "" || params[:bird][:number_banded] == ""
            flash[:message] = "Please complete all fields"
        elsif !Helpers.validate_alpha_code(params[:bird][:species][:code].strip)
            flash[:message] = "Please enter a valid alpha code."
        elsif params[:bird][:number_banded].to_i < 1
            flash[:message] = "Number banded must be greater than zero."
        elsif (find_species_by_code && !find_species_by_name) || (!find_species_by_code && find_species_by_name)
            flash[:message] = "The alpha code and name do not match - please verify"
                # elsif (!find_species_by_code && !find_species_by_name)
        #     flash[:message] = "This species is not currently in the database - do you wish to enter it?"
        #     ADD CODE TO HANDLE
        ## WARNING IF SPECIES IS ALREADY IN REPORT
        ## END VALIDATIONS
        else
            Helpers.check_date(params, session)
            @session = session
            @date_string = Helpers.date_string(session[:date])
            report = Report.find_by(:date => @date_string) || report = Report.create(:date => @date_string, :status => "draft")
            report.update(:date_slug => Helpers.slugify_date_string(@date_string)) if !report.date_slug
            report.bander = Helpers.current_bander(session) if !report.bander
            report.save
            params[:bird][:number_banded].to_i.times do
                bird = Bird.new(:banding_date => params[:date])
                bird.species = find_species_by_code || bird.species = Helpers.create_species(params[:bird][:species])
                bird.bander = Helpers.current_bander(session)
                bird.save
            end
            session.delete(:temp)
            redirect to "/reports/#{Helpers.slugify_date(@session[:date])}"
        end
        session[:temp] = {}
        session[:temp][:entered_alpha_code] = params[:bird][:species][:code].strip
        session[:temp][:entered_species_name] = params[:bird][:species][:name]
        session[:temp][:entered_number_banded] = params[:bird][:number_banded]
        redirect to '/birds/new'
    end

    post '/birds/cancel' do
        session.delete(:temp)
        if session[:date]
            redirect to "/reports/#{Helpers.slugify_date(session[:date])}"
        else
            redirect to "/home"
        end
    end

    get '/birds/:date/edit' do
        @date_string = Helpers.date_string(session[:date])
    
        redirect to "/reports/#{Helpers.slugify_date_string(@date_string)}/edit"
    end

    #  HELPERS
    helpers do
        def find_species_by_code
            Species.find_by(:code => params[:bird][:species][:code].strip.upcase)
        end

        def find_species_by_name
            Species.find_by(:name => params[:bird][:species][:name].strip.split(" ").map {|part| part.capitalize}.join(" "))
        end

    end

end