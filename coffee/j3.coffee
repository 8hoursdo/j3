root = this

j3 = root.j3 = ->
  j3.$.apply this, arguments

j3.version = '0.0.1'

j3.has = (obj, prop) ->
  obj.hasOwnProperty prop

j3.isUndefined = (obj) ->
  typeof obj is 'undefined'

j3.isArray = (obj) ->
  '[object Array]' is Object.prototype.toString.call obj

j3.$ = (id) ->
  if typeof id is 'string'
    return document.getElementById id
  return id
