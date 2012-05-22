do (j3) ->
  _pages = {}

  _curPage = null

  j3.getPage = (id) ->
    _pages[id]

  j3.Page = j3.cls j3.ContainerView,
    baseCss : 'page'

    show : ->
      if _curPage then _curPage.show()
      j3.Page.base().show.apply this, arguments
      _curPage = this

      @refresh()
      return

    refresh : ->
      @onRefresh?()

    onMessage : ->
      @_msgEvtMngr ?= j3.createEventManager()
      @_msgEvtMngr.on.apply @_msgEvtMngr, arguments

    unMessage : ->
      if not @_msgEvtMngr then return
      @_msgEvtMngr.un.apply @_msgEvtMngr, arguments

    notifyMessage : (name, sender, args) ->
      @onNotifyMessage? name, sender, args

      if not @_msgEvtMngr then return
      @_msgEvtMngr.fire name, sender, args
