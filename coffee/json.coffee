do (j3) ->
  rEncodeString = /\\|\r|\n|\t|"/g

  mEncodeString =
    '\\' : '\\\\'
    '\r' : '\\n'
    '\n' : '\\n'
    '\t' : '\\t'
    '"' : '\\"'

  fEncodeString = (match) -> mEncodeString[match]

  __stringToJson = (obj, buffer) ->
    buffer.append '"'
    buffer.append obj.replace rEncodeString, fEncodeString
    buffer.append '"'

  __arrayToJson = (obj, buffer) ->
    buffer.append '['

    firstItem = yes
    for item in obj
      if firstItem
        firstItem = no
      else
        buffer.append ','

      __toJson item, buffer
    buffer.append ']'

  __objectToJson = (obj, buffer) ->
    if j3.isFunction obj.toJson then return obj.toJson buffer

    buffer.append '{'

    firstItem = yes
    for key, value of obj
      if j3.isUndefined value then continue

      if firstItem
        firstItem = no
      else
        buffer.append ','

      __stringToJson key, buffer
      buffer.append ':'
      __toJson value, buffer

    buffer.append '}'


  __toJson = (obj, buffer) ->
    typeOfObj = typeof obj
    switch typeOfObj
      when 'string'
        buffer.append '"'
        buffer.append obj.replace rEncodeString, fEncodeString
        buffer.append '"'
      when 'number', 'boolean'
        buffer.append obj.toString()
      when 'object'
        if j3.isArray obj
          __arrayToJson obj, buffer
        else if j3.isDate obj
          buffer.append "\"/Date(#{obj.getTime()})/\""
        else if j3.isNull obj
          buffer.append 'null'
        else
          __objectToJson obj, buffer
      when 'undefined'
        buffer.append 'undefined'
      else
        __stringToJson obj.toString(), buffer
    return

  j3.toJSON = j3.toJson = (obj, buffer) ->
    if j3.isUndefined buffer
      buffer = new j3.StringBuilder
      __toJson obj, buffer
      buffer.toString()
    else
      __toJson obj, buffer

  j3.fromJSON = j3.fromJson = (json) ->
    eval "(#{json})"
