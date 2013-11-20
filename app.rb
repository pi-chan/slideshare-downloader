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

    puts path
    send_file(path)
    File.delete(path)
  end
end
