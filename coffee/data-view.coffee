j3.DataView =
  getDatasource : ->
    @_datasource

  setDatasource : (datasource) ->
    if @_datasource == datasource then return

    @_datasource = datasource
    datasource.bind this

  updateData : ->
    if not @_datasource then return
    if @_updatingData then return

    @_updatingData = true
    @onUpdateData()
    @_updatingData = false

  updateView : (datasource, eventName, args) ->
    if @_updatingData then return

    @_updatingData = true
    @onUpdateView datasource, eventName, args
    @_updatingData = false

