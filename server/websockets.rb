WEBSOCKET_HOST = ENV.fetch("WEBSOCKET_HOST", "0.0.0.0")
WEBSOCKET_PORT = ENV.fetch("WEBSOCKET_PORT", 8080)

class Websockets
  def self.start!
    EM::WebSocket.run(
      host: WEBSOCKET_HOST, port: WEBSOCKET_PORT
    ) { add_listeners }
  end

  def self.add_listeners(ws)
    ws.onopen &method(:on_websocket_open)
    ws.onclose &method(:on_websocket_close)
    ws.onmsg &method(:on_websocket_msg)
  end

  def self.on_websocket_open(handshake)
    puts "WebSocket connection open"
    # Access properties on the EM::WebSocket::Handshake object, e.g.
    # path, query_string, origin, headers
    # Publish message to the client
    ws.send "Hello Client, you connected to #{handshake.path}"
  end

  def self.on_websocket_close
  end

  def self.on_websocket_msg(msg)
    puts "Recieved message: #{msg}"
    ws.send "Pong: #{msg}"
  end

end