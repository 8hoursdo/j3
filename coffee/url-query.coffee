j3.UrlQuery = j3.cls
  ctor : ->
    @_query = {}
    return

  get : (name) ->
    if not @_query then return
    @_query[name]

  set : (name, value) ->
    @_query ?= {}
    @_query[name] = value

  unset : (name) ->
    if not @_query then return
    delete @_query[name]
  
  toString : ->
    sb = new j3.StringBuilder
    first = true
    for name, value of @_query
      if first then first = false else sb.a '&'
      sb.a name + '=' + encodeURIComponent(value)

    sb.toString()
