
methods = {}

methods.processItemId = (item) ->
  item = if item.toObject then item.toObject() else item
  item.id = item._id
  delete item._id
  item

module.exports = methods
