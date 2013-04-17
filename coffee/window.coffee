do (j3) ->
  __getActionButtons = (actions) ->
    if actions is 'okcancel'
      [
        cls : j3.Button, text : j3.Lang.ok, name : 'ok', primary : true
      ,
        cls : j3.Button, text : j3.Lang.cancel, name : 'cancel'
      ]
    else if actions is 'yesno'
      [
        cls : j3.Button, text : j3.Lang.yes, name : 'yes', primary : true
      ,
        cls : j3.Button, text : j3.Lang.no, name : 'no'
      ]
    else
      actions

  __elClose_click = (evt) ->
    @close 'cancel'

  __el_blur = (evt) ->

  j3.Window = j3.cls j3.ContainerView,
    baseCss : 'wnd'

    templateBegin : j3.template '<div id="<%=id%>" class="<%=css%>" style="display:none"><div class="wnd-header"><a class="close">&times;</a><h2 class="wnd-title"><%-title%></h2></div><div class="wnd-body"><div class="wnd-body-inner">'

    onInit : (options) ->
      @_title = options.title

      # save context data here if necessary.
      # you can get it by calling 'getContextData()' after the window closed to continue your work.
      @_contextData = options.contextData

      if j3.isUndefined options.autoFocusChild
        options.autoFocusChild = true
      @_autoFocusChild = !!options.autoFocusChild

    getTemplateData : ->
      id : @id
      css : @getCss()
      title : @_title
      windowActions : @_windowActions

    createChildren : (options) ->
      j3.Window.base().createChildren.apply this, arguments

      @createWindowChildren && @createWindowChildren options

      if options.actions
        @_windowActions = new j3.WindowActions
          parent : this
          children : __getActionButtons options.actions

    renderEnd : (buffer) ->
      buffer.append '</div>'
      buffer.append '</div>'

      if @_windowActions
        buffer.append '<div class="wnd-footer">'
        @_windowActions.render buffer
        buffer.append '</div>'

      buffer.append '</div>'

    renderChildren : (buffer) ->
      if not @children then return

      node = @children.firstNode()
      while node
        if node.value isnt @_windowActions
          node.value.render buffer
        node = node.next
      return

    onCreated : ->
      Dom = j3.Dom
      @_elWndHeader = Dom.firstChild @el
      @_elWndBody = Dom.next @_elWndHeader
      @_elWndFooter = Dom.next @_elWndBody

      @_elClose = Dom.firstChild @_elWndHeader
      @_elTitle = Dom.lastChild @_elWndHeader
      @elBody = Dom.firstChild @_elWndBody

      j3.on @_elClose, 'click', this, __elClose_click
      j3.on @el, 'blur', this, __el_blur

      @_dd = new j3.Drag
        el : @el
        trigger : @_elWndHeader
        invalidTriggerTypes : 'A'

    setTitle : (value) ->
      @_elTitle.innerHTML = j3.htmlEncode value

    getContextData : ->
      @_contextData

    setContextData : (value) ->
      @_contextData = value

    action : (name, src) ->
      args = name : name, src : src

      @onAction? args
      @fire 'action', this, args
 
    canLayout : ->
      @_visible

    show : ->
      zIndex = j3.Overlay.show()
      @el.style.zIndex = zIndex + 1
      j3.Dom.show @el
      @_visible = true

      @layout()

      j3.Dom.center @el

      if @_autoFocusChild
        j3.View.focusChild.call this

      @onActive && @onActive()
      @fire 'active', this

    close : (result, data) ->
      if not @_visible then return

      args =
        result : result
        data : data

      beforeClose? args
      if args.stop then return

      @fire 'beforeClose', this, args
      if args.stop then return

      @hide()
      @_visible = false
      j3.Overlay.hide()

      onClose? args
      @fire 'close', this, args

    getActionButton : (name) ->
      if not @_windowActions then return null
      @_windowActions.getActionButton name

    onSetHeight : (height) ->
      if not height
        # 窗口的高度根据内容自适应调整
        @el.style.height = ''
        @_elWndBody.style.height = ''
        @_elWndBody.firstChild.style.height = ''
        return

      Dom = j3.Dom
      Dom.offsetHeight @el, height
      bodyHeight = Dom.height(@el) - Dom.offsetHeight(@_elWndHeader)
      if @_elWndFooter
        bodyHeight -= Dom.offsetHeight(@_elWndFooter)
      Dom.offsetHeight @_elWndBody, bodyHeight
      Dom.offsetHeight @_elWndBody.firstChild, Dom.height @_elWndBody

    center : ->
      j3.Dom.center @el

    getVisible : ->
      @_visible
