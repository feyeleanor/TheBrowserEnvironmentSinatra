require 'sinatra'

set :server, %w[ thin mongrel webrick ]
set :bind, ENV['IP_ADDRESS'] || '0.0.0.0'
set :port, ENV['PORT'] || 3000
set :commands, [
	["interval", 3000],
	["timeout", 5000],
	["timeout", 7500],
	["interval", 1000]
]

get '/' do
	erb :html_13, locals: { commands: settings.commands  }
end
