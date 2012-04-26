do (j3) ->

  __compileRoutes = (routes) ->
    for match of routes
      handler = routes[match]
      if j3.isObject handler
        __compileRoutes handler

      if match isnt '$' and 0 is match.indexOf '$'
        routes['*'] = [
          match.substr 1
          handler
        ]
        
  
  __getHandler = (fragments, routes, params) ->
    fragment = ''
    while fragment is '' and fragments.length
      fragment = fragments.shift()

    if fragment is ''
      return routes.$
    else
      handler = routes[fragment]

      if !handler
        handler = routes['*']
        if !handler
          return null

        params[handler[0]] = fragment
        handler = handler[1]
      
      if j3.isFunction handler
        return handler
      else if j3.isObject handler
        return __getHandler fragments, handler, params

    return null


  j3.Router = j3.cls
    ctor : (options) ->
      @_routes = options.routes || {}
      __compileRoutes @_routes
      return

    handle : (path) ->
      fragments = path.split '/'

      params = {}
      handler = __getHandler fragments, @_routes, params
      if j3.isFunction handler then handler(params)
