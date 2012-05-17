do (j3) ->
  __renderTabsNav = (buffer) ->
    buffer.append '<ul class="tabs-triggers">'

    if @children
      node = @children.firstNode()
      while node
        panel = node.value

        buffer.append '<li'
        buffer.append ' id="' + panel.id + '-trigger"'
        if panel is @getActive()
          buffer.append ' class="active"'
        buffer.append '><a>'
        buffer.append j3.htmlEncode panel.getTitle()
        buffer.append '</a></li>'

        node = node.next

    buffer.append '</ul>'

  __hElTabsTriggers_Click = (evt) ->
    el = evt.src()

    while el and el isnt @_elTabsTriggers
      if el.tagName is 'LI'
        index = j3.Dom.indexOf el
        
        @setActive @children.getAt index

        return
      el = el.parentNode
    

  j3.Tabset = j3.cls j3.ContainerView,
    baseCss : 'tabs'

    onInit : (options) ->

    renderBegin : (buffer, data) ->
      buffer.append '<div id="' + data.id + '" class="' + data.css + '">'
      buffer.append '<div class="tabs-header">'

      __renderTabsNav.call this, buffer

      buffer.append '</div>'
      buffer.append '<div class="tabs-body">'
      return

    renderEnd : (buffer) ->
      buffer.append '</div></div>'

    onCreateChild : (options, args) ->
      options.cls ?= j3.TabPanel

    onChildCreated : (child, args, options) ->
      if options.active or args.index is 0
        @_activePanel = child

    onCreated : ->
      Dom = j3.Dom
      @_elTabsTriggers = Dom.firstChild Dom.firstChild @el

      j3.on @_elTabsTriggers, 'click', this, __hElTabsTriggers_Click

    getActive : ->
      @_activePanel

    setActive : (panel) ->
      if @_activePanel is panel then return
      if not panel then return

      old = @_activePanel
      Dom = j3.Dom
      if @_activePanel
        Dom.removeCls @_activePanel.elTrigger, 'active'
        Dom.removeCls @_activePanel.el, 'tab-pnl-active'

      @_activePanel = panel
      Dom.addCls @_activePanel.elTrigger, 'active'
      Dom.addCls @_activePanel.el, 'tab-pnl-active'

      @fire 'active', this, old : old, current : @_activePanel



