j3.EventManager =
  on : (name, context, handler) ->
    if not @_eventHandlers
      @_eventHandlers = {}


    if arguments.length == 1
      handlers = name
      for handlerName of handlers
        handlerList = @_eventHandlers[handlerName]
        if not handlerList
          @_eventHandlers[handlerName] = handlerList = new j3.List
        handlerList.insert handler : handlers[handlerName], context : null
    else
      if arguments.length == 2
        handler = context
        context = null

      handlerList = @_eventHandlers[name]
      if not handlerList
        @_eventHandlers[name] = handlerList = new j3.List
      handlerList.insert handler : handler, context : context
    this

  un : (name, context, handler) ->
    if not @_eventHandlers then return this

    handlerList = @_eventHandlers[name]
    if not handlerList then return this

    if arguments.length == 2
      handler = context
      context = null

    handlerList.removeNode handlerList.findNode
      handler : handler
      context : context
      equals : (obj) ->
        @handler is obj.handler and @context is obj.context
    this

  fire : (name, sender, args) ->
    if not @_eventHandlers then return this

    handlerList = @_eventHandlers[name]
    if not handlerList then return this

    handlerList.forEach (obj) ->
      obj.handler.call obj.context, sender, args
    this


