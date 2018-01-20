require 'quick_class'
require 'colored'
require 'active_support/all'
require 'em-websocket'
require 'sinatra/base'
require 'data_mapper'
require 'byebug'

require_relative './lib/game.rb'
require_relative './lib/websockets.rb'
require_relative './lib/database.rb'
require_relative './lib/auth_in_a_box.rb'

Thread.new { EM.run { Websockets.start! } }


class Server < Sinatra::Base

  enable :sessions

  get '/' do
    login_required
    "you're in"
  end

  get '/login' do
    render_login    # or render your own equivalent!
  end

  post '/login' do
    login
  end

  get '/signup' do
    render_signup   # or render your own equivalent!
  end

  post '/signup' do
    signup
  end

  get '/logout' do
    logout
  end
end