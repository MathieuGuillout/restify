# module dependencies
_        = require 'underscore'
mongoose = require 'mongoose'
Schema   = mongoose.Schema

# the rest methods defined
restMethods = require './restMethods'


# TO CALL A METHOD WITH WEB (EXPRESS)
webMethod = (method) ->
  (req, res) ->
    params = _.extend(params || {} , req[f]) for f in ["body", "query", "params", "files" ] when req[f]?
    method params, (err, result) -> res.send result


# Main method to apply route on a express erver
exports.restify = (options, done) ->

  # THE MODELS TO CREATE
  options.models ?= []

  # THE WEB SERVER (EXPRESS) TO ADD ROUTES TO
  options.app 
  
  # API ROUTE PREFIX
  options.apiRoutePrefix ?= "api"


  options.models.forEach (model) ->
    restMethods.forEach (method) ->
      route = "/#{options.apiRoutePrefix}/#{Object.keys(model)[0]}#{method.route}"
      options.app[method.verb.toLowerCase()](route, webMethod(method.do(model))) 

  options.app
