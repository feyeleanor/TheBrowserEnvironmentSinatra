require 'sinatra'
require 'sinatra-websocket'

set :server, %w[ thin mongrel webrick ]
set :bind, ENV['IP_ADDRESS'] || '0.0.0.0'
set :port, ENV['PORT'] || 3000
set :socket_url, ENV['SOCKET'] || '/'
set :commands, ["A", "B", "C"]

get '/' do
	if !request.websocket?
		erb :html_15, locals: { url: settings.socket_url, commands: settings.commands  }
	else
		request.websocket do |ws|
			ws.onopen do
				warn "websocket connected"
				ws.send "connection established"
			end

			ws.onmessage do |m|
				warn "received: #{m}\n"
				if settings.commands.include? m
					ws.send m
				else
					ws.send "unknown request #{m}"
				end
			end

			ws.onclose do
				warn "socket closed #{ws}"
			end
		end
	end
end