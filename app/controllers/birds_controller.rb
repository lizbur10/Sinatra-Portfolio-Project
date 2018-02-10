class BirdsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    # [Create]RUD
    get '/birds/new' do
        @session = session

        erb :'/birds/new'
    end

    post '/birds' do
        # Add warning if params[:date] != session[:date] && session[:date] exists
        if !Helpers.validate_alpha_code(params[:bird][:species][:code])
            flash[:message] = "Please enter a valid alpha code."
            redirect to '/birds/new'
        elsif params[:bird][:number_banded].to_i <= 0
            flash[:message] = "Number banded must be greater than zero."
            redirect to '/birds/new'
        elsif !find_species_by_code
            flash[:message] = "This alpha code is not in the database - please verify"
            redirect to '/birds/new'
        elsif !find_species_by_name
            flash[:message] = "The alpha code and name do not match - please verify"
            redirect to '/birds/new'
        end
        Helpers.check_date(params, session)
        @session = session
        @date_string = Helpers.date_string(session[:date])
        report = Report.find_by(:date => @date_string) || report = Report.create(:date => @date_string)
        report.update(:date_slug => Helpers.slugify_date_string(@date_string)) if !report.date_slug
        #report.bander = current_bander
        #report.save
        params[:bird][:number_banded].to_i.times do
            bird = Bird.new(:banding_date => params[:date])
            bird.species = find_species_by_code
            bird.save
        end
        redirect to "/birds/#{Helpers.slugify_date(@session[:date])}"
    end


    # C[Read]UD - ALL BIRDS FOR A GIVEN DATE
    get '/birds/:date' do
        Helpers.check_date(params, session)
        @session = session
        @date_slug = Helpers.slugify_date(session[:date])
        @date_string = Helpers.date_string(session[:date])
        @count_by_species = Helpers.count_by_species(@date_string)

        erb :'/birds/index'
    end


    ## CR[Update]D - EDIT BIRDS
    get '/birds/:date/edit' do
        Helpers.check_date(params, session)
        @date_string = Helpers.date_string(session[:date])
        @count_by_species = Helpers.count_by_species(@date_string)
        erb :'/birds/edit'
    end

    patch '/birds' do
        if !params[:cancel_changes]
            @date_string = Helpers.date_string(session[:date])
            params[:species].each do |species, value|
                if value.to_i < 0
                    flash[:message] = "Number banded cannot be negative."
                    redirect to "/birds/#{slugify_date_string(@date_string)}/edit"
                end
            end
            Helpers.update_banding_numbers(params,@date_string)
            
            if params[:add_more_birds]
                redirect to '/birds/new'
            else
                redirect to :"/birds/#{Helpers.slugify_date(session[:date])}" ## HAVE TO THINK ABOUT THIS
            end
        else
            redirect to :"/birds/#{Helpers.slugify_date(session[:date])}"
        end
    end



    #  HELPERS
    helpers do
        def find_species_by_code
            Species.find_by(:code => params[:bird][:species][:code])
        end

        def find_species_by_name
            Species.find_by(:name => params[:bird][:species][:name])
        end

    end

end