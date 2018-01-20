require 'quick_class'
require 'colored'
require 'active_support/all'
require 'em-websocket'
require 'sinatra/base'
require 'data_mapper'
require 'byebug'
require 'securerandom'

require_relative './lib/game.rb'
require_relative './lib/websockets.rb'
require_relative './lib/database.rb'
require_relative './lib/auth_in_a_box.rb'
require_relative './lib/auth_routes.rb'
require_relative './lib/token_manager.rb'

Thread.new { EM.run { Websockets.start! } }

class Server < Sinatra::Base

  CLIENT_ROOT_URL = "http://localhost:8081"

  enable :sessions

  extend AuthRoutes

  get '/' do
    login_required
    token = TokenManager.generate_token(current_user.id)
    redirect "#{CLIENT_ROOT_URL}?token=#{token}"
  end

end