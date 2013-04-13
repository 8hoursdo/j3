do (j3) ->

  j3.Drag = Drag = j3.cls
    ctor : (options) ->
      @_el = j3.$ options.el

      @_offsetX = options.offsetX || 0
      @_offsetY = options.offsetY || 0
      
      @_direction = options.direction || 3

      @_invalidTriggerTypes = options.invalidTriggerTypes
      @setTrigger options.trigger || options.el
      return

    getTrigger : ->
      @_elTrigger

    setTrigger : (trigger) ->
      trigger = j3.$ trigger

      if @_elTrigger
        j3.un @_elTrigger, 'mousedown', this, __trigger_mousedown
      if trigger
        j3.on trigger, 'mousedown', this, __trigger_mousedown

      @_elTrigger = trigger

    getEl : ->
      @_el

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

    getDragRect : ->
      deltaX = @_curX - @_startX
      deltaY = @_curY - @_startY

      if deltaX < 0
        left = @_startX + deltaX
      else
        left = @_startX
      if deltaY < 0
        top = @_startY + deltaY
      else
        top = @_startY

      left : left
      top : top
      width : Math.abs deltaX
      height : Math.abs deltaY

    onDrag : ->
      j3.Dom.place @getIndicator(), @_curPosX, @_curPosY

  j3.ext Drag.prototype, j3.EventManager

  __trigger_mousedown = (evt) ->
    if @_disabled then return
    @_dragTrigger = evt.src()

    if j3.include @_invalidTriggerTypes, @_dragTrigger.tagName, ',' then return

    @_startX = @_curX = evt.pageX()
    @_startY = @_curY = evt.pageY()

    body = document.body
    j3.on body, 'mousemove', this, __body_mousemove
    j3.on body, 'mouseup', this, __body_mouseup

    @_beginDragTimeout = setTimeout =>
      __beginDrag.call this
    , 2000
  
  __beginDrag = ->
    args =
      trigger : @_dragTrigger
      result : yes

    @beforeDrag && @beforeDrag args
    if not args.result then return

    @fire 'beforeDrag', this, args
    if not args.result then return

    pos = j3.Dom.position @_el

    @_curPosX = @_startPosX = pos.left + @_offsetX
    @_curPosY = @_startPosY = pos.top + @_offsetY

    body = document.body
    @_oldSelectStart = body.onselectstart
    body.onselectstart = j3.fnRetFalse
    j3.Dom.addCls(body, 'selectDisabled')

    @onDragStart && @onDragStart()
    @fire 'dragStart', this
    @_draging = true

  __body_mousemove = (evt) ->
    @_curX = evt.pageX()
    @_curY = evt.pageY()
    if not @_draging
      if Math.abs(@_curX - @_startX) > 5 or Math.abs(@_curY - @_startY) > 5
        clearTimeout @_beginDragTimeout
        __beginDrag.call this
      return
    
    direction = @_direction
    if direction & 1 then @_curPosX = @_startPosX + @_curX - @_startX
    if direction & 2 then @_curPosY = @_startPosY + @_curY - @_startY

    @onDrag()

  __body_mouseup = (evt) ->
    body = document.body
    j3.un body, 'mousemove', this, __body_mousemove
    j3.un body, 'mouseup', this, __body_mouseup

    clearTimeout @_beginDragTimeout
    if not @_draging then return

    body.onselectstart = @_oldSelectStart
    j3.Dom.removeCls body, 'selectDisabled'
    
    @onDragEnd && @onDragEnd()
    @fire 'dragEnd', this
    @_draging = false
