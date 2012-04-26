do (j3) ->
  _pages = {}

  _curPage = null

  j3.getPage = (id) ->
    _pages[id]

  j3.Page = j3.cls j3.ContainerView,
    show : ->
      if _curPage then _curPage.show()
      j3.Page.base().show.apply this, arguments
      _curPage = this
      return
