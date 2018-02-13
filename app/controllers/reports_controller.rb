class ReportsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    ## C[READ]UD - SHOW ALL REPORTS; LINK TO CREATE A NEW REPORT
    get '/reports' do
        @reports = Report.all.sort_by {|r| Date.parse(r.date)}.reverse

        erb :'/reports/index'
    end

    ## SUBMIT REPORT
    post '/reports/submit' do
        @date_string = Helpers.date_string(session[:date])
        report = Report.find_by(:date => @date_string)
        if report.bander_id == session[:bander_id]
            report.update(:status => "posted")
            flash[:message] = "***Success! Your report was successfully posted***"
            session.delete("date")
    
            redirect to :'/home'
        else
            flash[:message] = "You do not have permission to edit this report"
            redirect to "/reports/#{slugify_date_string(@date_string)}"
        end

    end

    ## [CREATE]RUD - CREATE NARRATIVE
    post '/reports/:date/add_narrative' do
        session[:show_narrative] = true
        redirect to :"/reports/#{Helpers.slugify_date(session[:date])}"
    end

    delete '/reports/:date/narrative' do
        @date_string = Helpers.date_string(session[:date])
        report = Report.find_by(:date => @date_string)
        report.content.clear
        report.save
        session[:show_narrative] = false
        redirect to :"/reports/#{Helpers.slugify_date(session[:date])}"
    end


    ## [CREATE]RUD - ADD NARRATIVE TO REPORT
    post '/reports/:date' do
        Helpers.check_date(params, session)
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
        Helpers.check_date(params, session)
        @date_string = Helpers.date_string(session[:date])
        report = Report.find_by(:date => @date_string)
        @show_narrative = true if session[:show_narrative]
        @narrative = report.content
        @bander = report.bander.name
        @date_slug = Helpers.slugify_date(session[:date])
        @count_by_species = Helpers.count_by_species(@date_string)
        erb :'/reports/show'
    end

    ## CR[UPDATE]D - EDIT REPORT
    get '/reports/:date/edit' do
        Helpers.check_date(params, session)
        @session = session
        @date_string = Helpers.date_string(session[:date])
        @count_by_species = Helpers.count_by_species(@date_string)
        report = Report.find_by(:date => @date_string)
        @narrative = report.content
        if report.bander_id == session[:bander_id]
            erb :'/reports/edit'
        else
            flash[:message] = "You do not have permission to edit this report"
            redirect to "/reports/#{slugify_date_string(@date_string)}"
        end

    end

    patch '/reports' do
        @date_string = Helpers.date_string(session[:date])
        binding.pry
        if !params[:cancel_changes]
            if params[:narrative]
                Report.find_by(:date => @date_string).update(:content => params[:narrative][:content])
            end
            if params[:species]
                Helpers.update_banding_numbers(params,@date_string)
            end
            redirect to '/birds/new' if params[:add_more_birds]
        end
        redirect to :"/reports/#{Helpers.slugify_date(session[:date])}"
    end
    
end