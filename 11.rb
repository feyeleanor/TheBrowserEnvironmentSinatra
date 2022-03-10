require 'sinatra'

set :server, %w[ thin mongrel webrick ]
set :bind, ENV['IP_ADDRESS'] || '0.0.0.0'
set :port, ENV['PORT'] || 3000

get '/' do
	erb :html_11
end
