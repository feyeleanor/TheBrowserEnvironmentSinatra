require 'websocket-eventmachine-client'
require 'json'

server = ENV['SERVER'] || '127.0.0.1:3000'
heartbeat = ENV['HEARTBEAT'] || 1
server_url = "ws://#{server}"
connected = false
count = 0

EM.run do
	puts "connecting to server: #{server_url}"
	ws = WebSocket::EventMachine::Client.connect(:uri => server_url)
	puts ws

	ws.onopen do
		puts "connected: #{server}"
		connected = true
	end

	ws.onmessage do |m, t|
		v = JSON.parse(m)
		case v["action"].to_sym
		when :PRINT
			puts "#{v["id"]}: #{v["message"]}"
		when :HEARTBEAT
			count = v["message"].to_i
			puts "#{v["id"]}: HEARTBEAT ==> #{count}"
		when :ERROR
			puts "ERROR: #{v["error"]} ==> #{v["message"]}"
		end
	end

	ws.onerror do |e|
		puts "error: #{e}"
	end

	ws.onclose do |c, m|
		puts "disconnected: #{server} (#{c}, #{m})"
		exit
	end

	timer = EventMachine::PeriodicTimer.new(heartbeat) do
		count += 1
		ws.send({ "action" => 'HEARTBEAT', "message" => count }.to_json) if connected
	end
end
