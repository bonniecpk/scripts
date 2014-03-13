require 'sinatra/base'
require 'slim'

class Mask < Sinatra::Application
  get '/' do
    slim :hello
  end
end

Mask.run!
