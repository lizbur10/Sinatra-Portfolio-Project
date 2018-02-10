class SessionsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    get '/sessions/login' do
        erb :'sessions/login'
    end

    post '/sessions' do
        @bander = Bander.find_by(name: params[:username].capitalize, password: params[:password])
        session[:bander_id] = @bander.id
        redirect '/reports'
    end
    
end