A small web server to display / update / add / remove entities

Dependencies
    
    express      = require 'express'
    connect      = require 'connect'
    yaml         = require 'js-yaml'
    bf           = require 'barefoot'
    restapi      = require 'restapi'

We load the configuration file

    path = process.cwd() 
    config = require "#{path}/config.yaml"

    api = new restapi("http://localhost:#{config.server.port}/api/")


We first create a web server

    app = express()


We apply the needed middlewares

    app.configure () ->
      app.use express.static "#{__dirname}/public"
      app.use express.cookieParser()
      app.use connect.bodyParser()
      app.use app.router


    app.get '/', bf.webService api.get("games")
    app.get '/models', bf.webService api.get("model/schema")


And finally, we start the web server

    config.web_server ?= {}
    config.web_server.port ?= 3001
    app.listen config.web_server.port
