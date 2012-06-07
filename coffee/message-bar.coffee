do (j3) ->
  j3.MessageBar = MessageBar = j3.cls j3.View,
    baseCss : 'msg-bar'

    template : j3.template '<div id="<%=id%>" class="<%=css%>"><div class="msg-bar-icon"></div><div class="msg-bar-content"></div></div>'

    onCreated : ->
      Dom = j3.Dom
      @_elIcon = Dom.firstChild @el
      @_elContent = Dom.next @_elIcon

    setIcon : (value) ->
      if @_icon is value then return

      @_icon = value
      @el.className = @getCss() + ' ' + @baseCss + '-' + @_icon
      @_elIcon.className = @baseCss + '-icon ' + @baseCss + '-icon-' + @_icon

    setContent : (value, encodeContent) ->
      if encodeContent
        value = j3.htmlEncode value

      @_elContent.innerHTML = value

    show : ->
      MessageBar.base().show.apply this, arguments
      j3.Dom.center @el, 30
      @_timerClose = setTimeout (=> @close()), 4000

    close : ->
      clearTimeout @_timerClose
      @hide()
      @fire 'close', this
 
  _pool = null
  __getPool = ->
    if _pool then return _pool

    _pool = new j3.Pool
      onCreate : (options) ->
        bar = new MessageBar options
        bar.on 'close', (sender, args) ->
          _pool.release sender

        bar

      onInit : (bar, options) ->
        bar.setIcon options.icon
        bar.setContent options.content, options.encodeContent
        bar._onCloseOnce = options.onClose
        bar.show()

  __genShowMethod = (icon) ->
    # show (options)
    # show (content, callback)
    # show (content, context, callback)
    (content, context, callback) ->
      if arguments.length is 1 and j3.isObject content
        options = content
      else
        if not callback
          callback = context
          context = null

        options =
          content : content
          onClose :
            handler : callback
            context : context

        options.icon = icon || options.icon

      __getPool().gain options
 
  j3.ext MessageBar,
    show : __genShowMethod(null)

    alert : __genShowMethod('warning')

    error : __genShowMethod('error')

    message : __genShowMethod('message')
