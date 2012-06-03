do (j3) ->
  __el_click = (evt) ->
    el = evt.src()

    while el and el isnt @el
      cmd = j3.Dom.attr el, 'data-cmd'
      if cmd
        evt.stop()
        __fireCommand.call this, cmd, el
        break

      el = el.parentNode

  __fireCommand = (name, el) ->
    elListItem = null
    while el and el isnt @el
      elListItem = el
      el = el.parentNode

    if el is @el
      data = @getDatasource().getAt j3.Dom.indexOf(elListItem)
      @fire 'command', this, name : name, data : data

  j3.DataList = j3.cls j3.View,
    baseCss : 'data-list'

    onInit : (options) ->
      @_dataItemCls = options.dataItemCls
      @_dataItemRenderer = options.dataItemRenderer

    onCreated : (options) ->
      j3.on @el, 'click', this, __el_click

      @setDatasource options.datasource

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
      index = 0
      if datasource
        activeModel = datasource.getActive()
        count = datasource.count
        datasource.forEach this, (model) ->
          dataListItem =
            index : index
            count : count
            data : model
            active : activeModel is model
            selected : false

          @renderDataListItem buffer, dataListItem
          index++

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

      buffer.append '<div class="' + itemCss + '">'

      @onRenderDataListItem buffer, dataListItem

      buffer.append '</div>'

    onRenderDataListItem : (buffer, dataListItem) ->
      if @_dataItemRenderer
        @_dataItemRenderer buffer, dataListItem
      else if not j3.isUndefined dataListItem.data
        buffer.append dataListItem.data.toString()

  j3.ext j3.DataList.prototype, j3.DataView
