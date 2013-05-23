Restify 
=======

module dependencies
-------------------

    _        = require 'underscore'
    mongoose = require 'mongoose'
    Schema   = mongoose.Schema
    bf       = require 'barefoot'



the rest methods to be defined
------------------------------


    restMethods = require './restMethods'



Main method to apply route on a express server
---------------------------------------------

    applyRestMethodsToModel = (app, route, name, model) ->
      restMethods.forEach (method) ->
        url = route + "#{name}#{method.route}:format?"

        verb = method.verb.toLowerCase()
        paramsMethod = {}
        paramsMethod[name] = model
        webMethod = bf.webService( method.do( paramsMethod ) )
        app[verb] url, webMethod


    exports.restify = (options, done) ->

      # The models to create
      options.model ?= []

      # The web server to add routes to
      options.app 
      
      # Api route prefix
      options.apiRoutePrefix ?= "api"

      route = "/#{options.apiRoutePrefix}/" 
      
      # Define a route for every model && every method
      Object.keys(options.model).forEach (model) ->
        applyRestMethodsToModel options.app, route, model, options.model[model]
  
      # Create routes & methods for the model's model
      applyRestMethodsToModel options.app, route, "model", options.model

      options.app
