do (j3) ->
  __el_click = (evt) ->
    el = evt.src()

    elListItem = null
    while el and el isnt @el
      cmd = j3.Dom.attr el, 'data-cmd'
      if cmd
        evt.stop()
        __fireCommand.call this, cmd, el
        break

      elListItem = el
      el = el.parentNode

    if el is @el
      __elListItem_click.call this, elListItem

  __elListItem_click = (el) ->
    datasource = @getDatasource()
    if datasource
      datasource.setActive datasource.getAt(j3.Dom.indexOf(el))

  __fireCommand = (name, src) ->
    elListItem = null
    el = src
    while el and el isnt @el
      elListItem = el
      el = el.parentNode

    if el is @el
      data = @getDatasource().getAt j3.Dom.indexOf(elListItem)

      args =
        name : name
        data : data
        src : src

      @onCommand? args
      @fire 'command', this, args

  j3.DataList = j3.cls j3.View,
    baseCss : 'data-list'

    _activeItemIndex : -1

    onInit : (options) ->
      @_dataItemCls = options.dataItemCls
      @_dataItemRenderer = options.dataItemRenderer

    onCreated : (options) ->
      j3.on @el, 'click', this, __el_click

      @setDatasource options.datasource

      if @_activeItemIndex is -1
        @_activeItenEl = null
      else
        @_activeItenEl = j3.Dom.byIndex @_activeItemIndex

    onUpdateView : (datasource, eventName, data) ->
      if not @el then return

      buffer = new j3.StringBuilder
      @renderDataListItems buffer, @getDatasource()
      @el.innerHTML = buffer.toString()

    onRender : (buffer, tplData) ->
      buffer.append '<div id="' + tplData.id + '" class="' + tplData.css + '">'
      @renderDataListItems buffer, @getDatasource()

      buffer.append '</div>'

    renderDataListItems : (buffer, datasource) ->
      if datasource
        activeModel = datasource.getActive()
        count = datasource.count
        datasource.forEach this, (model, args, index) ->
          dataListItem =
            index : index
            count : count
            data : model
            active : activeModel is model
            selected : false

          @renderDataListItem buffer, dataListItem

    renderDataListItem : (buffer, dataListItem) ->
      itemCss = 'list-item'
      if dataListItem.index is 0
        itemCss += ' list-item-first'
      else if dataListItem.index is (dataListItem.count - 1)
        itemCss += ' list-item-last'

      if dataListItem.index % 2
        itemCss += ' list-item-even'

      if dataListItem.active
        itemCss += ' list-item-active'
        @_activeItemIndex = dataListItem.index

      buffer.append '<div class="' + itemCss + '">'

      @onRenderDataListItem buffer, dataListItem

      buffer.append '</div>'

    onRenderDataListItem : (buffer, dataListItem) ->
      if @_dataItemRenderer
        @_dataItemRenderer buffer, dataListItem
      else if not j3.isUndefined dataListItem.data
        buffer.append dataListItem.data.toString()

  j3.ext j3.DataList.prototype, j3.DataView
