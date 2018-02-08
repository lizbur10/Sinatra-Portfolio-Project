class ReportsController < ApplicationController
    get '/reports' do
        @reports = Report.all.where(:status => "posted")
        erb :'/reports/index'
    end

    #ADD NARRATIVE
    get '/reports/:date/add_narrative' do
        @session = session
        @date_string = date_string
        report = Report.find_by(:date => date_string)
        if report.content && report.content != ""
            redirect to :"/reports/#{slugify_date(session[:date])}"
        else
            erb :'/reports/narrative'
        end
    end

    ## ADD NARRATIVE TO REPORT
    post '/reports/:date' do
        report = Report.find_by(:date => date_string)
        ## THROW WARNING IF NARRATIVE ALREADY EXISTS FOR DATE
        if params[:narrative][:content] && params[:narrative][:content] != ""
            report.content = params[:narrative][:content]
            report.save
        end
        redirect to :"/reports/#{slugify_date_string(report[:date])}"
    end
    

    helpers do
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

        def slugify_date_string(date_string)
            Helpers.slugify(date_string)
            # date_string.downcase.gsub(/\s/,"-")
        end

    end
    
end