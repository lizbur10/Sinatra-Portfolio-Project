class ReportsController < ApplicationController

    ## C[READ]UD - SHOW ALL REPORTS; LINK TO CREATE A NEW REPORT
    get '/reports' do
        @reports = Report.all
        erb :'/reports/index'
    end

    ## SUBMIT REPORT
    post '/reports/submit' do
        report = Report.find_by(:date => date_string).update(:status => "posted")
        session.delete("date")

        redirect to :'/reports'
    end

    ## [CREATE]RUD - CREATE NARRATIVE
    get '/reports/:date/add_narrative' do
        Helpers.check_date(params, session)
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
        @session = session
        @bander ="Anthony" ## HARD CODED UNTIL IMPLEMENT BANDER LOGIN
        @date_string = Helpers.date_string(session[:date])
        @narrative = Report.find_by(:date => @date_string).content
        @date_slug = Helpers.slugify_date(@session[:date])
        @count_by_species = Helpers.count_by_species(@date_string)
        erb :'/reports/show'
    end

    ## CR[UPDATE]D - EDIT REPORT
    get '/reports/:date/edit' do
        Helpers.check_date(params, session)
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
        end

        if params[:add_more_birds]
            redirect to '/birds/new'
        else
            redirect to :"/reports/#{Helpers.slugify_date(session[:date])}"
        end
    end
    
end