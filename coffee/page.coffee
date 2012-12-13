do (j3) ->
  _pages = {}

  _curPage = null

  j3.getPage = (id) ->
    _pages[id]

  j3.Page = j3.cls j3.ContainerView,
    baseCss : 'page'

    getPage : ->
      this

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

    getQuery : (name, defaultValue) ->
      if not @_query then @_query = new j3.UrlQuery
      @_query.get name, defaultValue

    setQuery : (name, value) ->
      if not @_query then @_query = new j3.UrlQuery
      @_query.set name, value

    unsetQuery : (name) ->
      if not @_query then return
      @_query.unset name

    commitQuery : ->
      # 即使queryString为空，任然保留井号，
      # 因为从有井号切换到没有井号时，浏览器会刷新。
      location.href = location.protocol + '//' + location.host + location.pathname + '#' + @queryString()

    queryString : ->
      if not @_query then @_query = new j3.UrlQuery
      @_query.toString()
