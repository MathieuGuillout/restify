ObjectID        = require('mongodb').ObjectID
utils           = require './utils'
mongoose        = require 'mongoose'
Schema          = mongoose.Schema

models = {}
modelOf = (model) ->
  name = Object.keys(model)[0]
  unless models[name]
    model[name].createdAt = type : Date
    model[name].updatedAt = type : Date
    schema = new Schema(model[name])
    schema.pre "save", (next) ->
      @updatedAt = new Date()
      @createdAt ?= new Date()
      next()

    models[name] = mongoose.model(name, schema)

  models[name]

# Methods to define on the api
module.exports = [
    description : "list" 
    route       : "s"
    verb        : "get" 
    do          : (model) ->
      (params, done) ->
        query = modelOf(model).find(params)
        props = modelOf(model).schema.paths
        # PREPOULATE LINKED FIELDS
        # OPTIMISE PROBABLY STORE IN TABLES OR ...
        query.populate(val.path) for prop, val of props when val.options.ref?
        query.exec (err, items) ->
          items = items.map(utils.processItemId)
          done err, items 
  ,
    description : "get one"
    route       : "s/:id"
    verb        : "get" 
    do          : (model) ->
      (params, done) ->
        modelOf(model).findOne { _id : new ObjectID(params.id) }, (err, item) ->
          done err, utils.processItemId(item)
  ,
    description : "add one" 
    route : "s"
    verb : "post" 
    do : (model) ->
      (params, done) ->
        modelName = Object.keys(model)[0]
        instance = new modelOf(model)(params[modelName])
        instance.save (err) ->
          done err, utils.processItemId(instance)
  ,
    description : "update one" 
    route : "s/:id"
    verb : "put" 
    do : (model) ->
      (params, done) ->
        idToUpdate = new ObjectID(params.id)
        update = params
        ["id", "_id"].forEach (x) -> delete update[x] if update[x]?
        modelOf(model).update { _id :  idToUpdate }, { $set : update }
        done null, params
  ,
    description : "delete one" 
    route : "s/:id"
    verb : "del" 
    do : (model) ->
      (params, done) ->
        idToRemove = new ObjectID(params.id)
        modelOf(model).remove { _id :  idToRemove }
        done null, params
  ]
