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

    refresh : (params) ->
      @_params = params
      @onRefresh && @onRefresh()

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

    getParam : (name) ->
      if not @_params then return
      @_params[name]

    getQuery : (name) ->
      if not @_query then return
      @_query.get name

    setQuery : (name, value) ->
      if not @_query then @_query = new j3.UrlQuery
      @_query.set name, value

    unsetQuery : (name) ->
      if not @_query then return
      @_query.unset name

    queryString : ->
      if not @_query then return ''
      @_query.toString()
