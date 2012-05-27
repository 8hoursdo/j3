do (j3) ->
  ViewInfo = (view, handler) ->
    @view = view
    @handler = handler
    return

  ViewInfo.prototype.equals = (obj) ->
    @view is obj.view and @handler is obj.handler

  j3.Datasource =
    bind : (view, handler) ->
      if not view then return

      if not @_views then @_views = new j3.List

      viewInfo = new ViewInfo view, handler
      if @_views.contains viewInfo then return

      @_views.insert viewInfo

      handler ?= view.updateView
      handler.call view, @, 'refresh'

    unbind : (view, handler) ->
      if not view then return

      if not @_views then return

      viewInfo = new ViewInfo view, handler
      if not @_views.contains viewInfo then return

      @_views.remove viewInfo

    updateViews : (eventName, args) ->
      if not @_views then return

      node = @_views.firstNode()
      while node
        viewInfo = node.value
        view = viewInfo.view
        handler = viewInfo.handler || view.updateView
        handler.call view, @, eventName, args
        node = node.next

      return
