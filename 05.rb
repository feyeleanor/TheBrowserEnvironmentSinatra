require 'sinatra'

set :server, %w[ thin mongrel webrick ]
set :bind, ENV['IP_ADDRESS'] || '0.0.0.0'
set :port, ENV['PORT'] || 3000
set :commands, ["A", "B", "C"]

get '/' do
	erb :html_05, locals: { commands: settings.commands  }
end

get '/:command' do
	if settings.commands.include?(params[:command])
		params[:command]
	else
		halt 404
	end
end