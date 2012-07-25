do (j3) ->
  j3.MessageBox = MessageBox = j3.cls j3.Window,
    renderChildren : (buffer) ->
      buffer.append '<div class="msg-box-icon"></div>'
      buffer.append '<div class="msg-box-content">'
      buffer.append '</div>'

    onCreated : (options) ->
      MessageBox.base().onCreated.apply this, arguments

      @_elMsgIcon = j3.Dom.firstChild @elBody
      @_elMsgContent = j3.Dom.next @_elMsgIcon

      @_btnOK = @getActionButton 'ok'
      @_btnCancel = @getActionButton 'cancel'

    onAction : (args) ->
      @close args.name

    setIcon : (value) ->
      @_elMsgIcon.className = 'msg-box-icon msg-box-icon-' + value

    setContent : (value, encodeContent) ->
      value ?= ''
      if encodeContent
        value = j3.htmlEncode value
      @_elMsgContent.innerHTML = value

    setButtons : (value) ->
      lang = j3.Lang
      switch value
        when 'okcancel'
          @_btnCancel.show()
          @_btnOK.setText lang.ok
          @_btnCancel.setText lang.cancel
        when 'ok'
          @_btnOK.setText lang.ok
          @_btnCancel.hide()
        when 'yesno'
          @_btnCancel.show()
          @_btnOK.setText lang.yes
          @_btnCancel.setText lang.no
        when 'yes'
          @_btnCancel.hide()
          @_btnOK.setText lang.yes
 
  _pool = null
  __getPool = ->
    if _pool then return _pool

    _pool = new j3.Pool
      onCreate : (options) ->
        options ?= {}
        options.actions = 'okcancel'
        wnd = new MessageBox options
        wnd.on 'close', (sender, args) ->
          if wnd._silentCloseByCancel and args.result is 'cancel'
            _pool.release sender
            return

          onClose = sender._onCloseOnce
          if onClose
            if j3.isFunction onClose
              onClose()
            else
              onClose.handler.apply onClose.context, arguments

          _pool.release sender

        wnd

      onInit : (wnd, options) ->
        wnd.setTitle options.title || ''
        wnd.setIcon options.icon
        wnd.setContent options.content, options.encodeContent
        wnd.setButtons options.buttons
        wnd._onCloseOnce = options.onClose
        wnd._silentCloseByCancel = options.silentCloseByCancel
        wnd.show()
        wnd._btnOK.focus()

  __genShowMethod = (icon, buttons, silentCloseByCancel) ->
    # show (options)
    # show (title, content, callback)
    # show (title, content, context, callback)
    (title, content, context, callback) ->
      if arguments.length is 1
        options = title
      else
        if not callback
          callback = context
          context = null

        options =
          title : title
          content : content
          onClose :
            handler : callback
            context : context

      options.icon = icon || options.icon
      options.buttons = buttons || options.buttons
      options.silentCloseByCancel = silentCloseByCancel || options.silentCloseByCancel
      options.title = options.title || j3.Lang[icon]

      __getPool().gain options
 
  j3.ext MessageBox,
    show : __genShowMethod(null, null)

    alert : __genShowMethod('warning', 'ok')

    error : __genShowMethod('error', 'ok')

    message : __genShowMethod('message', 'ok')

    confirm : __genShowMethod('confirm', 'okcancel', true)
