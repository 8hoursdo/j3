j3.Datasource =
  bind : (view) ->
    if not view then return

    if not @_views then @_views = new j3.List

    if @_views.contains view then return

    @_views.insert view

    view.updateView @

  unbind : (view) ->
    if not view then return

    if not @_views then return

    if not @_views.contains view then return

    @_views.remove view

  updateViews : ->
    if not @_views then return

    node = @_views.firstNode()
    while node
      node.value.updateView @
      node = node.next

    return
