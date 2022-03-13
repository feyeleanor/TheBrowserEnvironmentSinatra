require 'websocket-eventmachine-client'

server = ENV['SERVER'] || '127.0.0.1:3000'
server_url = "ws://#{server}"

EM.run do
	puts "connecting to server: #{server_url}"
	ws = WebSocket::EventMachine::Client.connect :uri => server_url
	puts ws

	ws.onopen do
		puts "connected: #{server}"
	end

	ws.onmessage do |m, t|
		puts m
	end

	ws.onerror do |e|
		puts "error: #{e}"
	end

	ws.onclose do |c, m|
		puts "disconnected: #{server} (#{c}, #{m})"
		exit
	end
end