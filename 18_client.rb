require 'websocket-eventmachine-client'

server = ENV['SERVER'] || 'localhost:3000'
heartbeat = ENV['HEARTBEAT'] || 2
commands = ["A", "B", "C", "D"]
server_url = "ws://#{server}"
connected = false

def rotate_buffer b
	r = b.shift
	b << r
	r
end

EM.run do
	puts "connecting to server: #{server_url}"
	ws = WebSocket::EventMachine::Client.connect(:uri => "ws://127.0.0.1:3000")
	puts ws

	ws.onopen do
		puts "connected: #{server}"
		connected = true
	end

	ws.onmessage do |m, t|
		puts m
	end

	ws.onerror do |e|
		puts "error: #{e}"
	end

	ws.onclose do |c, m|
		puts "disconnected: #{server} (#{c}, #{m})"
	end

	timer = EventMachine::PeriodicTimer.new(heartbeat) do
		ws.send rotate_buffer(commands) if connected
	end
end
