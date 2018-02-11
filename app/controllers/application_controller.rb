require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  get '/' do
    if Helpers.is_logged_in?(session)
      redirect to '/home'
    else
      erb :'/index'
    end
  end

  helpers do
    def slugify_date_string(date_string)
        Helpers.slugify(date_string)
    end
  end

end