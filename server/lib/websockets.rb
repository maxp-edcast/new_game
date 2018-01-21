class Websockets

  def self.add_listeners(ws)
    ws.onopen = -> (e) { Websockets.on_websocket_open ws, e }
    ws.onclose = -> (e) { Websockets.on_websocket_close ws, e }
    ws.onmessage = -> (msg) { Websockets.on_websocket_msg ws, msg }
  end

  def self.on_websocket_open(ws, event)
    puts "WebSocket connection open"
    # Access properties on the EM::WebSocket::Handshake object, e.g.
    # path, query_string, origin, headers
    # Publish message to the client
    ws.send "Hello Client, you connected"
  end

  def self.on_websocket_close(ws, event)
  end

  def self.on_websocket_msg(ws, msg)
    puts "Recieved message: #{msg}"
    ws.send "Pong: #{msg}"
  end

end