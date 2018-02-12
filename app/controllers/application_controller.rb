require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  get '/' do

    erb :'/index'
  end

  helpers do
    def slugify_date_string(date_string)
        Helpers.slugify(date_string)
    end
  end

end