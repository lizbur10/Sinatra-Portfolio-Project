class BirdsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    # [Create]RUD
    get '/birds/new' do
        @session = session

        erb :'/birds/new'
    end

    post '/birds' do
        # Ask to verify if params[:date] != session[:date] && session[:date] exists
        ## VALIDATIONS
        if !Helpers.validate_alpha_code(params[:bird][:species][:code])
            flash[:message] = "Please enter a valid alpha code."
        elsif params[:bird][:number_banded].to_i < 0
            flash[:message] = "Number banded must be greater than zero."
        elsif !find_species_by_code
            flash[:message] = "This alpha code is not in the database - please verify"
        elsif !find_species_by_name
            flash[:message] = "The alpha code and name do not match - please verify"
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
                bird.species = find_species_by_code
                bird.bander = Helpers.current_bander(session[:bander_id])
                bird.save
            end
            redirect to "/birds/#{Helpers.slugify_date(@session[:date])}"
        end
        redirect to '/birds/new'
    end


    # C[Read]UD - ALL BIRDS FOR A GIVEN DATE
    get '/birds/:date' do
        Helpers.check_date(params, session)
        @session = session
        @date_slug = Helpers.slugify_date(session[:date])
        @date_string = Helpers.date_string(session[:date])
        @count_by_species = Helpers.count_by_species(@date_string)
        @report = Report.find_by(:date => @date_string)
        if @report.status == "posted"
            redirect to "/reports/#{@date_slug}"
        end
        erb :'/birds/index'
    end


    ## CR[Update]D - EDIT BIRDS
    get '/birds/:date/edit' do
        Helpers.check_date(params, session)
        @date_string = Helpers.date_string(session[:date])
        @report = Report.find_by(:date => @date_string)
        @count_by_species = Helpers.count_by_species(@date_string)
        if @report.bander_id == session[:bander_id]
            erb :'/birds/edit'
        else
            flash[:message] = "You do not have permission to edit this report"
            redirect to "/birds/#{slugify_date_string(@date_string)}"
        end
    end

    patch '/birds' do
        if !params[:cancel_changes]
            @date_string = Helpers.date_string(session[:date])
            params[:species].each do |species, value|
                if value.to_i < 0
                    flash[:message] = "Number banded must be greater than zero."
                    redirect to "/birds/#{slugify_date_string(@date_string)}/edit"
                end
            end
            Helpers.update_banding_numbers(params,@date_string)
            redirect to '/birds/new' if params[:add_more_birds]
        end
        redirect to :"/birds/#{Helpers.slugify_date(session[:date])}"
    end



    #  HELPERS
    helpers do
        def find_species_by_code
            Species.find_by(:code => params[:bird][:species][:code].upcase)
        end

        def find_species_by_name
            Species.find_by(:name => params[:bird][:species][:name].titleize)
        end

    end

end