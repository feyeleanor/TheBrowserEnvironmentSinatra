require 'sinatra'
require 'sinatra-websocket'

set :server, %w[ thin mongrel webrick ]
set :bind, ENV['IP_ADDRESS'] || '0.0.0.0'
set :port, ENV['PORT'] || 3000
set :socket_url, ENV['SOCKET'] || '/'
set :commands, [:HEARTBEAT, :PRINT, :ERROR]
set :sockets, []
set :heartbeat, 0

def message id, a, m, e = nil
	{ "id" => id, "action" => a, "message" => m, "error" => e }
end

get '/' do
	if !request.websocket?
		erb :html_19, locals: { url: settings.socket_url, commands: settings.commands  }
	else
		request.websocket do |ws|
			ws.onopen do
				warn "websocket #{ws} connected"
				m = message 0, :PRINT, "connection opened: #{ws.object_id}"
				settings.sockets.each { |s| s.send m.to_json }
				ws.send message(0, :PRINT, "connection established: #{ws.object_id}").to_json
				ws.send message(0, :HEARTBEAT, settings.heartbeat).to_json
				settings.sockets << ws
			end

			ws.onmessage do |m|
				m = JSON.parse m
				m.merge! "id" => ws.object_id
				case m["action"].to_sym
				when :HEARTBEAT
					settings.heartbeat = m["message"].to_i
					EM.next_tick do
						settings.sockets.each do |s|
							s.send m.to_json
						end
					end
				when :PRINT
					EM.next_tick do
						settings.sockets.each do |s|
							s.send m.to_json if s != ws
						end
					end
				else
					ws.send message(0, :ERROR, m["message"], m["action"]).to_json
				end
			end

			ws.onclose do
				warn "socket closed #{ws}"
				settings.sockets.delete ws
				m = message(0, :PRINT, "connection closed: #{ws.object_id}").to_json
				settings.sockets.each { |s| s.send m }
			end
		end
	end
end
