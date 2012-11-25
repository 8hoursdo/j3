do (j3) ->
  __dataList_beforeItemClick = (sender, args) ->
    selectedItem = args.data
    if selectedItem.divider
      # 点击分割线
      args.stop = true
      return
    else if selectedItem.cmd
      # 点击命令项
      args.stop = true
      @close()
      @fire 'command', this,
        name : selectedItem.cmd
        data : selectedItem
      return

  # 列表项点击的事件处理
  __dataList_itemClick = (sender, args) ->
    # 更新控件时触发的事件不应该再次改变控件对外状态
    if @isUpdatingSubcomponent() then return

    # 一个列表中的项目被选中时，另一个列表中的当前选中项应该取消选中
    triggerDataList = sender
    if triggerDataList is @_dataList
      theOtherDataList = @_fixedDataList
    else
      theOtherDataList = @_dataList
    theOtherDataList && theOtherDataList.setSelectedItems null

    # 若选中项发生改变，则更新控件对外状态
    selectedItem = args.data
    if not j3.equals @_selectedValue, selectedItem.value
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
  __createDataList = (ctnr, datasource, itemDataSelector, handlerItemClick) ->
    if not datasource then return null

    dataList = new DropdownDataList
      parent : this
      ctnr : ctnr
      datasource : datasource
      selectedItemOnClick : yes
      selectedItems : @_selectedItems
      itemDataSelector : itemDataSelector
      on :
        beforeItemClick : c : this, h : __dataList_beforeItemClick
        itemClick : c : this, h : handlerItemClick

    dataList

  # 设置选中值，在控件初始化时以及外部调用setSelectedValue()时调用。
  # 返回选中值是否发生改变
  __doSetSelectedValue = (value) ->
    if j3.equals @_selectedValue, value then return false

    @_selectedValue = value
    __refreshControlViaSelectedValue.call this
    true

  # 当数据源发生改变时调用
  __itemsDatasource_onRefresh = ->
    __refreshControlViaSelectedValue.call this

  # 根据选中值，更新控件
  __refreshControlViaSelectedValue = ->
    # 更新下拉控件
    @updateSubcomponent()

    # 更新Selector
    @doSetSelectedItems __getSelectedItemFromDatasourceBySelectedValue.call this, @_selectedValue

    # 更新数据源的值
    @updateData()

  __getSelectedItemFromDatasourceBySelectedValue = (selectedValue) ->
    if selectedValue is null then return null

    selectedItem = null
    if @_fixedItemsDatasource
      fixedItemDataSelector = @_fixedItemDataSelector
      @_fixedItemsDatasource.tryUntil (item) ->
        itemData = fixedItemDataSelector item
        if itemData.value is selectedValue
          selectedItem = itemData
          return true

    if not selectedItem
      itemDataSelector = @_itemDataSelector
      @_itemsDatasource.tryUntil (item) ->
        itemData = itemDataSelector item
        if itemData.value is selectedValue
          selectedItem = itemData
          return true

    selectedItem

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
        @_fixedDataList = __createDataList.call this, elBox, @_fixedItemsDatasource, @_fixedItemDataSelector, __dataList_itemClick

      @_dataList = __createDataList.call this, elBox, @_itemsDatasource, @_itemDataSelector, __dataList_itemClick

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
      # 子控件未创建，无需更新状态
      if not @_dataList then return

      selectedValue = @_selectedValue

      if selectedValue is null
        if @_fixedDataList
          @_fixedDataList.setSelectedItems null
        @_dataList.setSelectedItems null
      else
        selectedItem = null
        if @_fixedDataList
          fixedItemDataSelector = @_fixedItemDataSelector
          @_fixedItemsDatasource.tryUntil (item) ->
            itemData = fixedItemDataSelector item
            if itemData.value is selectedValue
              selectedItem = itemData
              return true
          @_fixedDataList.setSelectedItem selectedItem

        if not selectedItem
          itemDataSelector = @_itemDataSelector
          @_itemsDatasource.tryUntil (item) ->
            itemData = itemDataSelector item
            if itemData.value is selectedValue
              selectedItem = itemData
              return true
          @_dataList.setSelectedItem selectedItem
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
