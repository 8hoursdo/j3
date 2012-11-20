do (j3) ->
  __dataList_beforeActiveItem = (sender, args) ->
    data = args.data
    if data.text is '-'
      args.stop = true
    else if data.cmd
      args.stop = true
      @close()
      @fire 'command', this,
        name : data.cmd
        data : data

  # 列表当前项改变的事件处理
  __dataList_activeItemChange = (sender) ->
    if @isUpdatingSubcomponent() then return

    triggerDataList = sender
    if triggerDataList is @_dataList
      theOtherDataList = @_fixedDataList
    else
      theOtherDataList = @_dataList

    theOtherDataList && theOtherDataList.getDatasource().setActive null

    selectedItem = sender.getActiveItem()

    @_selectedValue = selectedItem.value
    @doSetSelectedItems selectedItem
    @updateData()

    @onChange && @onChange()
    @fire 'change', this

    @close()

  # 默认的列表项数据选择器
  _defaultItemDataSelector = j3.compileSelector ['text', 'value', 'cmd']

  # 将数据项数组转换为数据集合
  __convertItemsToCollection = (items, datasource) ->
    if datasource then return datasource

    if not items then return null

    datasource = new j3.Collection
    j3.forEach items, (item) ->
      item.value ?= item.text
      datasource.insert item

    datasource

  # 创建数据列表控件
  __createDataList = (ctnr, datasource, itemDataSelector, handlerActiveItemChange) ->
    if not datasource then return null

    dataList = new DropdownDataList
      parent : this
      ctnr : ctnr
      datasource : datasource
      itemDataSelector : itemDataSelector
      activeItemOnClick : yes
      on :
        beforeActiveItem : c : this, h : __dataList_beforeActiveItem
        activeItemChange : c : this, h : handlerActiveItemChange

    dataList

  __doSetSelectedValue = (value) ->
    if @_selectedValue is value then return false

    @_selectedValue = value

    __refreshSelectedValueState.call this
    true

  __itemsDatasource_onRefresh = ->
    __refreshSelectedValueState.call this

  __refreshSelectedValueState = ->
    @updateSubcomponent()

    selectedModel = null
    if @_fixedItemsDatasource
      selectedModel = @_fixedItemsDatasource.getActive()
      if selectedModel
        @doSetSelectedItems @_fixedItemDataSelector selectedModel

    if not selectedModel
      selectedModel = @_itemsDatasource.getActive()
      if selectedModel
        @doSetSelectedItems @_itemDataSelector selectedModel

    if not selectedModel
      @doSetSelectedItems null

    @updateData()


  j3.DropdownList = j3.cls j3.Dropdown,
    _selectedIndex : null

    onInit : (options) ->
      j3.DropdownList.base().onInit.call this, options

      @_itemsDatasource = __convertItemsToCollection(options.items, options.itemsDatasource) || new j3.Collection
      @_fixedItemsDatasource = __convertItemsToCollection options.fixedItems, options.fixedItemsDatasource

      @_itemDataSelector = j3.compileSelector(options.itemDataSelector || _defaultItemDataSelector)
      @_fixedItemDataSelector = j3.compileSelector(options.fixedItemDataSelector || _defaultItemDataSelector)

    onCreated : (options) ->
      j3.DropdownList.base().onCreated.call this

      if j3.isUndefined options.value
        @doSetSelectedItems null
      else
        __doSetSelectedValue.call this, options.value
      @setDatasource options.datasource

      @_itemsDatasource.on 'refresh', this, __itemsDatasource_onRefresh

    onCreateDropdownBox : (elBox) ->
      if @_fixedItemsDatasource
        @_fixedDataList = __createDataList.call this, elBox, @_fixedItemsDatasource, @_fixedItemDataSelector, __dataList_activeItemChange

      @_dataList = __createDataList.call this, elBox, @_itemsDatasource, @_itemDataSelector, __dataList_activeItemChange

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

    setSelectedValue : (value) ->
      if not __doSetSelectedValue.call this, value then return

      @onChange && @onChange()
      @fire 'change', this

    onSetSelectedItems : ->
      if @getMultiple()
      else
        selectedItem = @getSelectedItem()
        @_selectedValue = if selectedItem then selectedItem.value else null

        @updateSubcomponent()
        @updateData()

    onUpdateData : ->
      @_datasource.set @name, @_selectedValue

    onUpdateView : (datasource, eventName, args) ->
      if args and args.changedData and not args.changedData.hasOwnProperty @name then return
      @setSelectedValue datasource.get @name

    onUpdateSubcomponent : ->
      selectedValue = @_selectedValue

      if selectedValue is null
        if @_fixedItemsDatasource
          @_fixedItemsDatasource.setActive null
        @_itemsDatasource.setActive null
      else
        selectedModel = null
        if @_fixedItemsDatasource
          fixedItemDataSelector = @_fixedItemDataSelector
          selectedModel = @_fixedItemsDatasource.tryUntil (item) ->
            fixedItemDataSelector(item).value is selectedValue
          @_fixedItemsDatasource.setActive selectedModel

        if not selectedModel
          itemDataSelector = @_itemDataSelector
          selectedModel = @_itemsDatasource.tryUntil (item) ->
            itemDataSelector(item).value is selectedValue
          @_itemsDatasource.setActive selectedModel
      return

  j3.ext j3.DropdownList.prototype, j3.DataView


  DropdownDataList = j3.cls j3.DataList,
    css : 'drp-list'

    onRenderDataListItem : (sb, dataListItem) ->
      itemData = dataListItem.data

      textDisplay = j3.getVal(itemData, 'text') or j3.getVal(itemData, 'name') or j3.getVal(itemData, 'value')
      if textDisplay is '-'
        sb.a '<div class="drp-list-divider"></div>'
      else
        sb.a '<a>'
        sb.a textDisplay
        sb.a '</a>'
