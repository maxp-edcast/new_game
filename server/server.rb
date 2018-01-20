require 'quick_class'
require 'colored'
require 'active_support/all'
require 'em-websocket'
require 'sinatra/base'
require 'data_mapper'

require_relative './lib/game.rb'
require_relative './lib/websockets.rb'
require_relative './lib/database.rb'

Thread.new { EM.run { Websockets.start! } }