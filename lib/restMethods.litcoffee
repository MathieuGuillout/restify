Dependencies
------------

    ObjectID        = require('mongodb').ObjectID
    mongoose        = require 'mongoose'
    Schema          = mongoose.Schema


Our list of models
------------------

    models = {}

Give the corresponding mongoose model for a object describing the model


    modelOf = (model) ->
      name = Object.keys(model)[0]
      indexes = []
      unless models[name]
        # Add default created and updated properties
        model[name].createdAt = type : Date
        model[name].updatedAt = type : Date

        # Check for specific types (Location, ...)
        for property, type of model[name]
          if type == "Location"
            model[name][property] = { longitude : Number, latitude : Number }
            index = {}
            index[property] = "2d"
            indexes.push index

        # Create schema and indexes
        schema = new Schema(model[name])
        indexes.forEach (index) -> schema.index(index)

        schema.pre "save", (next) ->
          @updatedAt = new Date()
          @createdAt ?= new Date()
          next()

        models[name] = mongoose.model(name, schema)

      models[name]


Remove format and ... parameters

    processParams = (params) ->
      delete(params.format) if params?
      params

_id => id 

    processItemId = (item) ->
      item = item.toObject() if item.toObject
      item.id = item._id
      delete item._id
      item

 Methods to define on the api



    module.exports = [
        description : "list" 
        route       : "s"
        verb        : "get" 
        do          : (model) ->
          (params, done) ->
            params = processParams(params)
            console.log params
            query = modelOf(model).find(params)
            props = modelOf(model).schema.paths
            query.populate(val.path) for prop, val of props when val.options.ref?
            query.exec (err, items) ->
              console.log(err) if err?
              done err, items.map(processItemId)
      ,
        description : "get one"
        route       : "s/:id"
        verb        : "get" 
        do          : (model) ->
          (params, done) ->
            modelOf(model).findOne { _id : new ObjectID(params.id) }, (err, item) ->
              done err, processItemId(item)
      ,
        description : "add one" 
        route : "s"
        verb : "post" 
        do : (model) ->
          (params, done) ->
            modelName = Object.keys(model)[0]
            if not params? or not params[modelName]?
              done null, null
            else
              params[modelName] = processParams(params[modelName])
              if params[modelName].id 
                idToUpdate = new ObjectID(params[modelName].id)
                toUpdate =  params[modelName]
                delete toUpdate.id
                modelOf(model).update { _id :  idToUpdate }, { $set : toUpdate }, (err) ->
                  params[modelName].id = idToUpdate
                  done err, params[modelName]
              else
                instance = new modelOf(model)(params[modelName])
                instance.save (err) ->
                  console.log(err) if err?
                  done err, processItemId(instance)


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
