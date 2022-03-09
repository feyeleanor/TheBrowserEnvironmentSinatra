require 'sinatra'

set :server, %w[ thin mongrel webrick ]
set :bind, ENV['IP_ADDRESS'] || '0.0.0.0'
set :port, ENV['PORT'] || 3000
set :commands, ["A", "B", "C"]

get '/' do
	erb :html_03, locals: { commands: settings.commands  }
end

get '/:command' do
	params[:command]
end