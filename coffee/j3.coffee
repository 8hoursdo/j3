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

j3.isNullOrUndefined = (obj) ->
  @isNull(obj) or @isUndefined(obj)

toString = Object.prototype.toString

j3.isDate = (obj) ->
  '[object Date]' is toString.call obj

j3.isArray = (obj) ->
  '[object Array]' is toString.call obj

j3.isDateTime = (obj) ->
  obj instanceof j3.DateTime


j3.clone = (obj, properties) ->
  if not @isObject obj then return obj

  if obj is null then return null

  if @isDate obj then return new Date obj.getTime()

  if @isArray obj
    res = []
    for item in obj
      res.push j3.clone item
    return res

  if @isFunction obj.clone then return obj.clone properties

  res = {}
  if arguments.length == 1
    for prop of obj
      res[prop] = j3.clone obj[prop]
  else
    for prop in properties
      if obj.hasOwnProperty prop
        res[prop] = j3.clone obj[prop]
  res

j3.equals = (obj1, obj2) ->
  if typeof obj1 isnt typeof obj2 then return false

  if @isNull obj1 then return @isNull obj2

  if not @isObject obj1 then return obj1 is obj2

  if @isDate obj1 then return obj1.getTime() is obj2.getTime()

  if @isArray obj1
    if obj1.length isnt obj2.length then return false

    i = -1
    while ++i < obj1.length
      if not j3.equals obj1[i], obj2[i] then return false
    return true

  if @isFunction obj1.equals then return obj1.equals obj2

  if @isObject(obj1) and @isObject(obj2)
    for key of obj1
      if not @equals obj1[key], obj2[key] then return false
    return true

  return false

j3.compare = (obj1, obj2, nullGreat) ->
  # deal null value
  if @isNullOrUndefined obj1
    if @isNullOrUndefined obj2 then return 0
    if nullGreat then return 1 else return -1
  else if @isNullOrUndefined obj2
    if nullGreat then return -1 else return 1

  # deal date time
  if @isDateTime(obj1) or @isDate(obj1)
    obj1 = obj1.getTime()
  if @isDateTime(obj2) or @isDate(obj2)
    obj2 = obj2.getTime()

  # deal object with compare
  if @isObject obj1
    if @isFunction obj1.compare
      return obj1.compare obj2
    else if not @isObject obj2
      return 1

  if @isObject obj2
    if @isFunction obj2.compare
      return obj2.compare obj1
    else if not @isObject obj1
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
