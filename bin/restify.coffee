#!/usr/bin/env coffee

# Dependencies
express      = require 'express'
connect      = require 'connect'
yaml         = require 'js-yaml'
fs           = require 'fs'
mongoose     = require 'mongoose'
program      = require 'commander'

# Lib
restify      = require './../lib/restify'

# Command line options
program
  .version('0.0.1')
  .option('-c, --config', 'the path to the yml config file, by default config.yaml')
  .option('-d, --debug',  'run restify in debug mode (false by default)')
  .parse(process.argv);

# Load the configuration file
path = process.cwd() 
program.config ?= "#{path}/config.yaml"
params = require program.config

mongoose.connect(params.server.db)

# CREATE A WEB SERVER
app = express()

# WEB SERVER CONFIGURATION 
app.configure () ->
  app.use express.static "#{__dirname}/../public"
  app.use express.cookieParser()
  app.use connect.bodyParser()
  app.use app.router

# ERROR HANDLING 
app.configure 'development', () -> 
  app.all '*', (req, res, next) -> 
    console.error(new Date(), req.route.method, req.url) if program.debug
    next()

  app.use express.errorHandler({
    dumpExceptions : true, 
    showStack : true
  })

app.configure 'production', () -> 
  app.use express.errorHandler()


# APPLY ALL ROUTE DEFINITIONS
#app = routes.applyTo app
params.app = app
restify.restify params, (err, app) ->
  app = app

# STARTING THE WEB SERVER
params.server ?= {}
params.server.port ?= 3000
app.listen params.server.port
