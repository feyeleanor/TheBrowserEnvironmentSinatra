require 'sinatra'

set :server, %w[ thin mongrel webrick ]
set :bind, ENV['IP_ADDRESS'] || '0.0.0.0'
set :port, ENV['PORT'] || 3000
set :commands, {
	"A": ["B", "C"],
	"B": ["A", "C"],
	"C": ["A", "B"]
}

get '/' do
	erb :html_08, locals: { commands: settings.commands  }
end