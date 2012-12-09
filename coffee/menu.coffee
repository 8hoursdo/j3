do (j3) ->
  j3.Menu = j3.cls j3.View,
    baseCss : 'menu'

    template : j3.template '<div id="<%=id%>" class="<%=css%>"></div>'

    onInit : (options) ->
      @_items = options.items || []

    onCreated : (options) ->
      j3.on @el, 'click', this, __hMenuClick
        
    popup : (options) ->
      Dom = j3.Dom

      __genMenuItems.call this

      if options.contextData
        @_contextData = options.contextData

      trigger = options.trigger
      if trigger
        position = Dom.position trigger
        triggerHeight = trigger.offsetHeight

        options.x = position.left
        if options.alignRight
          options.x += trigger.offsetWidth
        options.y = position.top + triggerHeight

      # giv the trigger a chance to decide if a menu item should be hiden or disabled.
      __updateItemsUI.call this

      Dom.show @el

      posX = options.x
      posY = options.y
      if options.alignRight
        posX -= @el.offsetWidth
      Dom.place @el, posX, posY

      j3.regPopup this, 'menu'

    close : ->
      j3.Dom.hide @el
      j3.unregPopup this, 'menu'

    getContextData : ->
      @_contextData

    setContextData : (value) ->
      if @_contextData is value then return

      @_contextData = value

  __renderMenuItems = (sb, items) ->
    sb.a '<ul class="menu-items">'
    for item in items
      j3.MenuItem.render sb, item
    sb.a '</ul>'

  __genMenuItems = ->
    if @_elMenuItems then return

    buffer = new j3.StringBuilder
    __renderMenuItems.call this, buffer, @_items
    @el.innerHTML = buffer.toString()

    @_elMenuItems = @el.firstChild
    @_menuItems = []
    elMenuItem = @_elMenuItems.firstChild
    i = 0
    while elMenuItem
      item = @_items[i]
      @_menuItems.push new j3.MenuItem
        parent : this
        el : elMenuItem
        divider : item.divider
        text : item.text
        name : item.name
        icon : item.icon
      elMenuItem = elMenuItem.nextSibling
      i++

  __hMenuClick = (evt) ->
    el = evt.src()
    while el and el isnt @el
      if el.tagName is 'A'
        cmd = el.attributes['data-cmd']
        if cmd and cmd.nodeValue
          evt.stop()
          @close()
          @fire 'command', this, name : cmd.nodeValue, contextData : @_contextData
          return

      el = el.parentNode

  __updateItemsUI = ->
    if not @_menuItems then return
    for menuItem in @_menuItems
      @fire 'updateItemUI', this, item : menuItem

