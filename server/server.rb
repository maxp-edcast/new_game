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
require_relative './lib/auth_routes.rb'

Thread.new { EM.run { Websockets.start! } }


class Server < Sinatra::Base

  enable :sessions
  extend AuthRoutes

end