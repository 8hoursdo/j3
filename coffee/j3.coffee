root = this

j3 = ->
  j3.$.apply this, arguments

if typeof exports isnt 'undefined'
  if typeof module isnt 'undefined'
    module.exports = j3
  else
    exports.j3 = j3
else
  root.j3 = j3

j3.version = '0.0.2'

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

j3.isString = (obj) ->
  typeof obj is 'string'

j3.isObject = (obj) ->
  typeof obj is 'object'

j3.isNull = (obj) ->
  obj is null

toString = Object.prototype.toString

j3.isDate = (obj) ->
  '[object Date]' is toString.call obj

j3.isArray = (obj) ->
  '[object Array]' is toString.call obj


j3.clone = (obj) ->
  if not @isObject obj then return obj

  if @isDate obj then return new Date obj.getTime()

  if @isArray obj
    res = []
    for item in obj
      res.push j3.clone item
    return res

  if @isFunction obj.clone then return obj.clone()

  res = {}
  @ext res, obj
  res

j3.equals = (obj1, obj2) ->
  if typeof obj1 isnt typeof obj2 then return false

  if not @isObject obj1 then return obj1 is obj2

  if @isDate obj1 then return obj1.getTime() is obj2.getTime()

  if @isArray obj1
    if obj1.length isnt obj2.length then return false

    i = -1
    while ++i < obj1.length
      if not j3.equals obj1[i], obj2[i] then return false
    return true

  if @isFunction obj1.equals then return obj1.equals obj2

  return false

j3.$ = (id) ->
  if typeof id is 'string'
    return document.getElementById id
  return id
