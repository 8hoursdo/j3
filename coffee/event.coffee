do (j3) ->
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

  j3.on = (el, eventName, handler, context) ->
    handlerInfo =
      e : el
      n : eventName
      h : handler
      c : context
      f : if arguments.length == 3 then handler else -> handler.call context, arguments[0]

    _handlerInfoList.insert handlerInfo

    if el.addEventListener
      el.addEventListener eventName, handlerInfo.f, true
    else
      el.attachEvent 'on' + eventName, handlerInfo.f

    return

  j3.un = (el, eventName, handler, context) ->
    node = _handlerInfoList.firstNode()
    while node
      info = node.value
      if info.e is el and info.n is eventName and info.h is handler and info.context is context then break
      node = node.next

    if !node then return

    __detachEvent node.value
    _handlerInfoList.removeNode node

    return

  j3.ready = (handler, context) ->
    f = if arguments.length == 1 then handler else -> handler.call context, arguments[0]

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
    

