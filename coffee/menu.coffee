do (j3) ->
  j3.Menu = j3.cls j3.View,
    baseCss : 'menu'

    template : j3.template '<div id="<%=id%>" class="<%=css%>"></div>'

    onInit : (options) ->
      @_items = options.items || []

    onCreated : (options) ->
      @_hidden = yes
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
      # hide dividers at first or last of visible menu items, hide duplicate dividers.
      __hideDividers.call this

      @show()
      if options.width
        @width options.width
      else
        @width(-1)

      posX = options.x
      posY = options.y
      if options.alignRight
        posX -= @el.offsetWidth
      Dom.place @el, posX, posY

      j3.regPopup this, 'menu', trigger

    close : ->
      @hide()
      j3.unregPopup this, 'menu'
      @fire 'close', this

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
          cmdArgs =
            name : cmd.nodeValue
            contextData : @_contextData

          @onCommand && @onCommand cmdArgs
          @fire 'command', this, cmdArgs
          return

      el = el.parentNode

  __updateItemsUI = ->
    if not @_menuItems then return
    for menuItem in @_menuItems
      @fire 'updateItemUI', this,
        name : menuItem.name
        item : menuItem
        contextData : @_contextData

  __hideDividers = ->
    for menuItem in @_menuItems
      if menuItem.getDivider()
        menuItem.setVisible true

    isFirst = true
    prevVisibleDividerItem = null

    for menuItem in @_menuItems
      if menuItem.getDivider()
        if isFirst or prevVisibleDividerItem
          menuItem.setVisible false
        else
          menuItem.setVisible true
          prevVisibleDividerItem = menuItem
      else if menuItem.getVisible()
        isFirst = false
        prevVisibleDividerItem = null

    if prevVisibleDividerItem
      prevVisibleDividerItem.setVisible false


