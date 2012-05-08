do (j3) ->
  __renderMenuItems = (buffer, items) ->
    buffer.append '<ul class="menu-items">'
    for item in items
      isDivider = item.text is '-'

      buffer.append '<li class="menu-item'
      if isDivider
        buffer.append ' menu-divider'
      buffer.append '">'

      if not isDivider
        buffer.append '<a data-cmd="'
        buffer.append item.name
        buffer.append '">'
        buffer.append '<i'
        if item.icon
          buffer.append 'class="' + item.icon + '"'
        buffer.append '></i>'
        buffer.append j3.htmlEncode item.text
        buffer.append '</a>'

      buffer.append '</li>'
    buffer.append '<ul>'

  __genMenuItems = ->
    if @_elMenuItems then return

    buffer = new j3.StringBuilder
    __renderMenuItems.call this, buffer, @_items
    @el.innerHTML = buffer.toString()

  __hMenuClick = (evt) ->
    el = evt.src()
    while el and el isnt @el
      if el.tagName is 'A'
        cmd = el.attributes['data-cmd']
        if cmd and cmd.nodeValue
          evt.stop()
          @close()
          @fire 'command', this, name : cmd.nodeValue, data : @_data
          return

      el = el.parentNode

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

      if options.data
        @_data = options.data

      trigger = options.trigger
      if trigger
        position = Dom.position trigger
        triggerHeight = trigger.offsetHeight

        options.x = position.left
        if options.alignRight
          options.x += trigger.offsetWidth
        options.y = position.top + triggerHeight

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
