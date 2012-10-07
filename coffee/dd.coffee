do (j3) ->

  j3.DD = DD = j3.cls
    ctor : (options) ->
      @_el = j3.$ options.el
      
      @_offsetX = options.offsetX || 0
      @_offsetY = options.offsetY || 0
      
      @_direction = options.direction || 3

      @_invalidTriggerTypes = options.invalidTriggerTypes
      @setTrigger options.trigger || options.el
    
    setTrigger : (trigger) ->
      trigger = j3.$ trigger
      if trigger
        j3.on trigger, 'mousedown', this, __trigger_mousedown

    startDrag : (trigger) ->
      args =
        trigger : trigger
        result : yes

      @beforeDrag && @beforeDrag args
      if not args.result then return

      @fire 'beforeDrag', this, args
      if not args.result then return

      pos = j3.Dom.position @_el

      @_curPosX = @_startPosX = pos.left + @_offsetX
      @_curPosY = @_startPosY = pos.top + @_offsetY

      body = document.body
      j3.on body, 'mousemove', this, __body_mousemove
      j3.on body, 'mouseup', this, __body_mouseup

      @_oldSelectStart = body.onselectstart
      body.onselectstart = j3.fnRetFalse
      j3.Dom.addCls(body, 'selectDisabled')

      @onDragStart && @onDragStart()
      @fire 'dragStart', this

    getIndicator : ->
      @_el

    getStartX : ->
      @_startX

    getStartY : ->
      @_startY

    getCurX : ->
      @_curX

    getCurY : ->
      @_curY

    getStartPosX : ->
      @_startPosX

    getStartPosY : ->
      @_startPosY

  j3.ext DD.prototype, j3.EventManager

  __trigger_mousedown = (evt) ->
    if @_disabled then return
    trigger = evt.src()

    if j3.include @_invalidTriggerTypes, trigger.tagName, ',' then return

    @_startX = evt.pageX()
    @_startY = evt.pageY()
  
    @startDrag trigger

  __body_mousemove = (evt) ->
    @_curX = evt.pageX()
    @_curY = evt.pageY()
    
    direction = @_direction
    if direction & 1 then @_curPosX = @_startPosX + @_curX - @_startX
    if direction & 2 then @_curPosY = @_startPosY + @_curY - @_startY

    @onDrag && @onDrag()

    j3.Dom.place @getIndicator(), @_curPosX, @_curPosY

  __body_mouseup = (evt) ->
    body = document.body
    j3.un body, 'mousemove', this, __body_mousemove
    j3.un body, 'mouseup', this, __body_mouseup

    body.onselectstart = @_oldSelectStart
    j3.Dom.removeCls body, 'selectDisabled'
    
    @onDragEnd && @onDragEnd()
    @fire 'dragEnd', this
