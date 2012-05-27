j3.DataItemsView =
  getItemsDatasource : ->
    @_itemsDatasource

  setItemsDatasource : (datasource) ->
    if @_itemsDatasource == datasource then return

    @_itemsDatasource = datasource
    if datasource then datasource.bind this, this.updateViewItems

  updateViewItems : (datasource, eventName, args) ->
    if @_updatingViewItems then return

    @_updatingViewItems = true
    @onUpdateViewItems && @onUpdateViewItems datasource, eventName, args
    @_updatingViewItems = false

