class BirdsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    # [Create]RUD
    get '/birds/new' do
        @session = session
        ## CONTROL FOR SITUATION WHERE NO REPORTS EXIST YET
        if !session[:date]
            @date = Report.all.map{|r| Date.parse(r.date)}.max + 1.day
            @date = @date.strftime("%b %d")
        else
            @date = session[:date].strftime("%b %d")
        end
        erb :'/birds/new'
    end

    post '/birds' do
        # Ask to verify if params[:date] != session[:date] && session[:date] exists
        ## VALIDATIONS
        if !Helpers.validate_alpha_code(params[:bird][:species][:code].strip)
            flash[:message] = "Please enter a valid alpha code."
        elsif params[:bird][:number_banded].to_i < 1
            flash[:message] = "Number banded must be greater than zero."
        elsif (find_species_by_code && !find_species_by_name) || (!find_species_by_code && find_species_by_name)
            flash[:message] = "The alpha code and name do not match - please verify"
        # elsif (!find_species_by_code && !find_species_by_name)
        #     flash[:message] = "This species is not currently in the database - do you wish to enter it?"
        #     ADD CODE TO HANDLE
        ## END VALIDATIONS
        else
            Helpers.check_date(params, session)
            @session = session
            @date_string = Helpers.date_string(session[:date])
            report = Report.find_by(:date => @date_string) || report = Report.create(:date => @date_string, :status => "draft")
            report.update(:date_slug => Helpers.slugify_date_string(@date_string)) if !report.date_slug
            report.bander = Helpers.current_bander(session[:bander_id]) if !report.bander
            report.save
            params[:bird][:number_banded].to_i.times do
                bird = Bird.new(:banding_date => params[:date])
                bird.species = find_species_by_code || bird.species = Helpers.create_species(params[:bird][:species])
                bird.bander = Helpers.current_bander(session[:bander_id])
                bird.save
            end
            redirect to "/reports/#{Helpers.slugify_date(@session[:date])}"
        end
        redirect to '/birds/new'
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