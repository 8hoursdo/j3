root = this

j3 = ->
  j3.$.apply this, arguments

if typeof exports isnt 'undefined'
  if typeof module isnt 'undefined' and module.exports
    exports = module.exports = j3
  else
    exports.j3 = j3
else
  root.j3 = j3

j3.version = '0.0.1'

j3.isRunInServer = ->
  j3.UA.name is 'server'

j3.has = (obj, prop) ->
  obj.hasOwnProperty prop

j3.isUndefined = (obj) ->
  typeof obj is 'undefined'

j3.isBoolean = (obj) ->
  typeof obj is 'boolean'

j3.isFunction = (obj) ->
  typeof obj is 'function'

j3.isNull = (obj) ->
  obj is null

toString = Object.prototype.toString

j3.isDate = (obj) ->
  '[object Date]' is toString.call obj

j3.isArray = (obj) ->
  '[object Array]' is toString.call obj

j3.$ = (id) ->
  if typeof id is 'string'
    return document.getElementById id
  return id
