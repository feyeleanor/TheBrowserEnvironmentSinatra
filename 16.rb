require 'sinatra'
require 'sinatra-websocket'

set :server, %w[ thin mongrel webrick ]
set :bind, ENV['IP_ADDRESS'] || '0.0.0.0'
set :port, ENV['PORT'] || 3000
set :socket_url, ENV['SOCKET'] || '/'
set :commands, ["A", "B", "C"]
set :sockets, []

get '/' do
	if !request.websocket?
		erb :html_16, locals: { url: settings.socket_url, commands: settings.commands  }
	else
		request.websocket do |ws|
			ws.onopen do
				warn "websocket #{ws} connected"
				m = "connection opened: #{ws.object_id}"
				settings.sockets.each { |s| s.send m }
				settings.sockets << ws
				ws.send "connection established: #{ws.object_id}"
			end

			ws.onmessage do |m|
				if settings.commands.include? m
					EM.next_tick do
						ws.send "message sent: #{m}"
						m = "message received from #{ws.object_id}: #{m}"
						settings.sockets.each { |s| s.send m unless s == ws }
					end
				else
					ws.send "unknown command: #{m}"
				end
			end

			ws.onclose do
				warn "socket closed #{ws}"
				settings.sockets.delete ws
				m = "connection closed: #{ws.object_id}"
				settings.sockets.each { |s| s.send  m }
			end
		end
	end
end
