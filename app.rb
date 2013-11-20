Bundler.require

if development?
  require "sinatra/reloader" 
  require 'debugger'
end

require './helpers'

class App < Sinatra::Base
  get "/" do
    haml :index
  end

  get "/main.js" do
    coffee :main
  end

  post "/download" do
    url = params["url"]
    dl = Helpers::Downloader.new(url)
    path = dl.exec()
    unless path
      @failed = true
      return haml :index
    end

    # You should remove the 'path' file after this action.
    # But on Heroku, 'path' file must not be manually deleted.
    send_file(path)
  end
end
