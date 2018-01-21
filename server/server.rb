require 'quick_class'
require 'colored'
require 'active_support/all'
require 'faye/websocket'
require 'sinatra/base'
require 'data_mapper'
require 'byebug'
require 'securerandom'
# require 'thin'

require_relative './lib/game.rb'
require_relative './lib/websockets.rb'
require_relative './lib/database.rb'
require_relative './lib/auth_in_a_box.rb'
require_relative './lib/auth_routes.rb'
require_relative './lib/token_manager.rb'

Faye::WebSocket.load_adapter('thin')

class Server < Sinatra::Base

  # set :server, 'thin'

  CLIENT_ROOT_URL = ENV.fetch "CLIENT_ROOT_URL", "http://localhost:8080"

  enable :sessions

  extend AuthRoutes

  get '/' do
    if Faye::WebSocket.websocket?(request.env)
      ws = Faye::WebSocket.new(request.env)
      Websockets.add_listeners ws
      ws.rack_response
    else
      login_required
      token = TokenManager.generate_token(current_user.id)
      redirect "#{CLIENT_ROOT_URL}?token=#{token}"
    end
  end

end
