do (j3) ->
  # 列表当前项改变的事件处理
  __dataList_activeItemChange = (sender) ->
    selectedItem = sender.getActiveItem()

    @_selectedValue = selectedItem.value
    @doSetSelectedItems selectedItem
    @updateData()

    @onChange && @onChange()
    @fire 'change', this

    @close()

  _defaultItemDataSelector = j3.compileSelector ['text', 'value']

  j3.DropdownList = j3.cls j3.Dropdown,
    _selectedIndex : null

    onInit : (options) ->
      j3.DropdownList.base().onInit.call this, options

      if options.itemsDatasource
        @_itemsDatasource = options.itemsDatasource
      else
        datasource = new j3.Collection
        items = options.items
        if items
          j3.forEach items, (item) ->
            item.value ?= item.text
            datasource.insert item
        @_itemsDatasource = datasource

      @_itemDataSelector = j3.compileSelector(options.itemDataSelector || _defaultItemDataSelector)

    onCreated : (options) ->
      j3.DropdownList.base().onCreated.call this

      if j3.isUndefined options.value
        @doSetSelectedItems null
      else
        @setSelectedValue options.value
      @setDatasource options.datasource

    onCreateDropdownBox : (elBox) ->
      @_dataList = new DropdownDataList
        parent : this
        ctnr : elBox
        datasource : @_itemsDatasource
        itemDataSelector : @_itemDataSelector
        activeItemOnClick : yes

      @_dataList.on 'activeItemChange', this, __dataList_activeItemChange

    getItemsDatasource : ->
      @_itemsDatasource

    getItems : () ->
      @_items

    setItems : (items) ->
      datasource = new j3.Collection
      if items
        j3.forEach items, (item) ->
          item.value ?= item.text
          datasource.insert item

      @_itemsDatasource = datasource
      if @_dataList then @_dataList.setDatasource @_itemsDatasource

    getSelectedValue : ->
      @_selectedValue

    setSelectedValue : (value, internal) ->
      if @_selectedValue is value then return

      @_selectedValue = value

      selectedItem = @_itemsDatasource.tryUntil (item) ->
        if value is j3.getVal(item, 'value')
          return true
        else
          return false
      @_itemsDatasource.setActive selectedItem

      if selectedItem
        @doSetSelectedItems @_itemDataSelector selectedItem
      else
        @doSetSelectedItems null

      @onChange && @onChange()
      @fire 'change', this

      @updateData()

    onSetSelectedItems : ->
      if @getMultiple()
      else
        selectedItem = @getSelectedItem()
        if selectedItem then @setSelectedValue selectedItem.value, true

    onUpdateData : ->
      @_datasource.set @name, @_selectedValue

    onUpdateView : ->
      @setSelectedValue @_datasource.get @name

  j3.ext j3.DropdownList.prototype, j3.DataView


  DropdownDataList = j3.cls j3.DataList,
    css : 'drp-list'

    onRenderDataListItem : (sb, dataListItem) ->
      itemData = dataListItem.data
      sb.a '<a>'
      sb.a j3.getVal(itemData, 'text') or j3.getVal(itemData, 'name') or j3.getVal(itemData, 'value')
      sb.a '</a>'
