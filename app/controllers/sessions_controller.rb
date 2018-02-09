class SessionsController < ApplicationController
    require 'rack-flash'
    use Rack::Flash

    get '/sessions/login' do
        erb :'sessions/login'
    end
end