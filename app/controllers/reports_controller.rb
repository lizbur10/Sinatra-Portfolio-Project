class ReportsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    ## C[READ]UD - SHOW ALL REPORTS; LINK TO CREATE A NEW REPORT
    get '/reports' do
        if Helpers.is_logged_in?(session)
            @reports = Report.all.sort_by {|r| Date.parse(r.date)}.reverse

            erb :'/reports/index'
        else
            redirect to '/login'
        end

    end

    ## SUBMIT REPORT
    post '/reports/submit' do
        @date_string = Helpers.date_string(session[:date])
        report = Report.find_by(:date => @date_string)
        if report.bander_id == session[:bander_id]
            report.update(:status => "posted")
            flash[:message] = "***Success! Your report has been posted"
            session.delete("date")
            session.delete("show_narrative")
    
            redirect to :'/home'
        else
            ## This should never fire
            flash[:message] = "You do not have permission to edit this report"
            redirect to "/reports/#{slugify_date_string(@date_string)}"
        end

    end

    ## [CREATE]RUD - CREATE NARRATIVE
    post '/reports/:date/add_narrative' do
        session[:show_narrative] = true
        redirect to :"/reports/#{Helpers.slugify_date(session[:date])}"
    end

    ## OBSOLETE
    delete '/reports/:date/narrative' do
        @date_string = Helpers.date_string(session[:date])
        report = Report.find_by(:date => @date_string)
        report.content.clear
        report.save
        session[:show_narrative] = false
        redirect to :"/reports/#{Helpers.slugify_date(session[:date])}"
    end
    ##


    ## [CREATE]RUD - ADD NARRATIVE TO REPORT
    post '/reports/:date' do
        Helpers.check_date(params, session)
        @date_string = Helpers.date_string(session[:date])
        report = Report.find_by(:date => @date_string)
        if params[:narrative][:content] && params[:narrative][:content] != ""
            report.content = params[:narrative][:content]
            report.save
        end
        redirect to :"/reports/#{Helpers.slugify_date_string(report[:date])}"
    end

    ## C[READ]UD - SHOW SPECIFIC REPORT
    get '/reports/:date' do
        if Helpers.is_logged_in?(session)
            Helpers.check_date(params, session)
            @date_string = Helpers.date_string(session[:date])
            report = Report.find_by(:date => @date_string)
            @show_narrative = true if session[:show_narrative]
            @narrative = report.content
            @bander = report.bander
            @date_slug = Helpers.slugify_date(session[:date])
            @count_by_species = Helpers.count_by_species(@date_string)
            if @bander == Helpers.current_bander(session)
                erb :'/reports/show'
            else
                redirect to "/reports/#{@date_slug}/preview"
            end
        else
            redirect to '/login'
        end

    end

    get '/reports/:date/preview' do
        ## ADD MARGINAL TOTALS AND GRAND TOTAL TO POSTED REPORT
        if Helpers.is_logged_in?(session)
            Helpers.check_date(params, session)
            @date_string = Helpers.date_string(session[:date])
            report = Report.find_by(:date => @date_string)
            @show_narrative = true if session[:show_narrative]
            @narrative = report.content
            @bander = report.bander
            @date_slug = Helpers.slugify_date(session[:date])
            @count_by_species = Helpers.count_by_species(@date_string)
            if @bander == Helpers.current_bander(session)
                @edit_access = true
            else
                session.delete(:date)
            end
            binding.pry
            
            erb :'/reports/preview'
        else
            redirect to '/login'
        end
            
    end

    ## CR[UPDATE]D - EDIT REPORT
    get '/reports/:date/edit' do
        if Helpers.is_logged_in?(session)
            Helpers.check_date(params, session)
            @session = session
            @date_string = Helpers.date_string(session[:date])
            @count_by_species = Helpers.count_by_species(@date_string)
            report = Report.find_by(:date => @date_string)
            @narrative = report.content
            if report.bander_id == session[:bander_id]
                erb :'/reports/edit'
            else
                redirect to "/reports/#{slugify_date_string(@date_string)}/preview"
            end
        else
            redirect to '/login'
        end

    end

    patch '/reports' do
        @date_string = Helpers.date_string(session[:date])
        if !params[:cancel_changes]
            if params[:species]
                session[:temp] = {}
                params[:species].each do |species_code, number|
                    # NEED TO ADD DELETE CHECKBOXES TO SAVED PARAMS
                    session[:temp]["#{species_code}"] = number
                    if number.to_i < 0
                        flash[:message] = "Number banded must be greater than zero."
                    end
                end
                if params[:delete]
                    session[:temp][:delete] = {}
                    params[:delete].each do |species_code, value|
                        session[:temp][:delete]["#{species_code}"] = value
                    end
                end
                if flash[:message]
                    redirect to "/reports/#{Helpers.slugify_date_string(@date_string)}/edit"
                else
                    Helpers.update_banding_numbers(params,@date_string,session)
                    session.delete(:temp) if session[:temp]
                end
            elsif params[:narrative]
                Report.find_by(:date => @date_string).update(:content => params[:narrative][:content])
                session[:show_narrative] = false if params[:narrative][:content] == ""

                redirect to :"/reports/#{Helpers.slugify_date_string(@date_string)}/preview"
            end
            session.delete(:temp) if session[:temp]  ## DOUBLE-CHECK PLACEMENT
            redirect to '/birds/new' if params[:add_more_birds]
        end
        redirect to "/reports/#{slugify_date_string(@date_string)}"
    end
    
end