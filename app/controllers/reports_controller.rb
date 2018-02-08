class ReportsController < ApplicationController
    get '/reports' do
        @reports = Report.all.where(:status => "posted")
        erb :'/reports/index'
      end
    
end