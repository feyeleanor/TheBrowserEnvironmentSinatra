require 'sinatra'

set :server, %w[ thin mongrel webrick ]
set :bind, ENV['IP_ADDRESS'] || '0.0.0.0'
set :port, ENV['PORT'] || 3000
set :commands, {
	"A" => 300,
	"B" => 700,
	"C" => 500
}

get '/' do
	erb :html_14, locals: { commands: settings.commands  }
end

get '/:command' do
	if settings.commands.include? params[:command]
		settings.commands[params[:command]].to_s
	else
		halt 404
	end
end