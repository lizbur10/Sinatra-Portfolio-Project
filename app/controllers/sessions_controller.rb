class SessionsController < ApplicationController

    get '/sessions/login' do
        erb :'sessions/login'
    end
end