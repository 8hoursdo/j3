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

j3.version = '0.3.18'

j3.fnRetFalse = -> false

j3.isRunInServer = ->
  j3.UA.name is 'server'

j3.has = (obj, prop) ->
  obj.hasOwnProperty prop

j3.isUndefined = (obj) ->
  typeof obj is 'undefined'

j3.isBoolean = (obj) ->
  typeof obj is 'boolean'

j3.isNumber = (obj) ->
  typeof obj is 'number'

j3.isFunction = (obj) ->
  typeof obj is 'function'

j3.isString = (obj) ->
  typeof obj is 'string'

j3.isObject = (obj) ->
  typeof obj is 'object'

j3.isNull = (obj) ->
  obj is null

j3.isNullOrUndefined = (obj) ->
  j3.isNull(obj) or j3.isUndefined(obj)

toString = Object.prototype.toString

j3.isDate = (obj) ->
  '[object Date]' is toString.call obj

j3.isArray = (obj) ->
  '[object Array]' is toString.call obj

j3.isDateTime = (obj) ->
  obj instanceof j3.DateTime

j3.bind = (fn, context, args) ->
  if args
    -> fn.apply context, args
  else
    -> fn.call context

j3.clone = (obj, properties, ignoreUndefined) ->
  if not j3.isObject obj then return obj

  if obj is null then return null

  if j3.isDate obj then return new Date obj.getTime()

  if j3.isArray obj
    res = []
    for item in obj
      res.push j3.clone item
    return res

  if j3.isFunction obj.clone then return obj.clone properties

  res = {}
  if arguments.length == 1
    for prop of obj
      res[prop] = j3.clone obj[prop]
  else
    for prop in properties
      if obj.hasOwnProperty prop
        if ignoreUndefined
          if not j3.isUndefined obj[prop]
            res[prop] = j3.clone obj[prop]
        else
          res[prop] = j3.clone obj[prop]
  res

j3.equals = (obj1, obj2) ->
  if typeof obj1 isnt typeof obj2 then return false

  if j3.isNull obj1 then return j3.isNull obj2

  if not j3.isObject obj1 then return obj1 is obj2

  if j3.isDate obj1 then return obj1.getTime() is obj2.getTime()

  if j3.isArray obj1
    if not obj2 then return false

    if obj1.length isnt obj2.length then return false

    i = -1
    while ++i < obj1.length
      if not j3.equals obj1[i], obj2[i] then return false
    return true

  if j3.isFunction obj1.equals then return obj1.equals obj2

  if j3.isObject(obj1) and j3.isObject(obj2)
    for key of obj1
      if not j3.equals obj1[key], obj2[key] then return false
    return true

  return false

j3.compare = (obj1, obj2, nullGreat) ->
  # deal null value
  if j3.isNullOrUndefined obj1
    if j3.isNullOrUndefined obj2 then return 0
    if nullGreat then return 1 else return -1
  else if j3.isNullOrUndefined obj2
    if nullGreat then return -1 else return 1

  # deal date time
  if j3.isDateTime(obj1) or j3.isDate(obj1)
    obj1 = obj1.getTime()
  if j3.isDateTime(obj2) or j3.isDate(obj2)
    obj2 = obj2.getTime()

  # deal object with compare
  if j3.isObject obj1
    if j3.isFunction obj1.compare
      return obj1.compare obj2
    else if not j3.isObject obj2
      return 1

  if j3.isObject obj2
    if j3.isFunction obj2.compare
      return obj2.compare obj1
    else if not j3.isObject obj1
      return -1

  if obj1 is obj2
    return 0
  else if obj1 > obj2
    return 1
  else
    return -1

j3.$ = (id) ->
  if typeof id is 'string'
    return document.getElementById id
  return id

j3.guid = ->
  s = ""
  for i in [1...33]
    n = Math.floor(Math.random()*16.0).toString(16)
    s += n
    if i==8 or i==12 or i==16 or i==20 then s += "-"
  s
