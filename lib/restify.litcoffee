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

    exports.restify = (options, done) ->

      # THE MODELS TO CREATE
      options.models ?= []

      # THE WEB SERVER (EXPRESS) TO ADD ROUTES TO
      options.app 
      
      # API ROUTE PREFIX
      options.apiRoutePrefix ?= "api"


      options.models.forEach (model) ->
        restMethods.forEach (method) ->
          route = "/#{options.apiRoutePrefix}/" 
          route += "#{Object.keys(model)[0]}#{method.route}:format?"

          options.app[method.verb.toLowerCase()](route, bf.webService(method.do(model))) 

      options.app
