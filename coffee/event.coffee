do (j3) ->
  Event = (@event) ->

  if j3.UA.ie
    j3.ext Event.prototype,
      src : ->
        @event.srcElement
      button : ->
        switch @event.button
          when 1 then return 1
          when 2 then return 3
          when 4 then return 2
          else return 0
      leftButton : ->
        @event.button is 1
      rightButton : ->
        @event.button is 2
      middleButton : ->
        @event.button is 4
      pageX : ->
        @event.clientX + document.documentElement.scrollLeft
      pageY : ->
        @event.clientY + document.documentElement.scrollTop
      stop : ->
        @event.returnValue = false
        @event.cancelBubble = true
  else
    j3.ext Event.prototype,
      src : ->
        @event.target
      button : ->
        @event.which
      leftButton : ->
        @event.which is 1
      rightButton : ->
        @event.which is 3
      middleButton : ->
        @event.which is 2
      pageX : ->
        @event.pageX
      pageY : ->
        @event.pageY
      stop : ->
        @event.preventDefault()
        @event.stopPropagation()
    

  _handlerInfoList = new j3.List
  _readyHandlerList = new j3.List

  __detachEvent = (handlerInfo) ->
    el = handlerInfo.e
    eventName = handlerInfo.n
    if el.removeEventListener
      el.removeEventListener eventName, handlerInfo.f, true
    else
      el.detachEvent eventName, handlerInfo.f

    delete handlerInfo.e
    delete handlerInfo.h
    delete handlerInfo.f

    return

  j3.on = (el, eventName, context, handler) ->
    if arguments.length == 3
      handler = context

    handlerInfo =
      e : el
      n : eventName
      h : handler
      c : context
      f : -> handler.call context, new Event arguments[0]

    _handlerInfoList.insert handlerInfo

    if el.addEventListener
      el.addEventListener eventName, handlerInfo.f, true
    else
      el.attachEvent 'on' + eventName, handlerInfo.f

    return

  j3.un = (el, eventName, context, handler) ->
    if arguments.length == 3
      handler = context

    node = _handlerInfoList.firstNode()
    while node
      info = node.value
      if info.e is el and info.n is eventName and info.h is handler and info.context is context then break
      node = node.next

    if !node then return

    __detachEvent node.value
    _handlerInfoList.removeNode node

    return

  j3.ready = (context, handler) ->
    f = if arguments.length == 1 then context else -> handler.call context, arguments[0]

    _readyHandlerList.insert f


  j3.on window, 'load', ->
    node = _readyHandlerList.firstNode()
    while node
      node.value()
      node = node.next
    return

  j3.on window, 'unload', ->
    node = _handlerInfoList.firstNode()
    while node
      handlerInfo = node.value
      __detachEvent handlerInfo
      node = node.next
    

