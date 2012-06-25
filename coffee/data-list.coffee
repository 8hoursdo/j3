do (j3) ->
  # 点击列表事件处理
  __el_click = (evt) ->
    el = evt.src()

    elListItem = null
    while el and el isnt @el
      # 如果点击了包含data-cmd属性的元素，则触发command事件
      cmd = j3.Dom.attr el, 'data-cmd'
      if cmd
        evt.stop()
        __fireCommand.call this, cmd, el

        # 如果点击了command元素，不再处理列表项被点击事件（至少目前是这样子的）
        return

      # 在向上查找父节点之前，记录当前节点。
      # 当循环结束后，elListItem记录的就是被点击的那个列表项的元素
      elListItem = el
      el = el.parentNode

    # 如果elListItem不为null（为null的话，就是直接点击了@el）
    # 则进行点击列表项事件的处理
    if elListItem and el is @el
      __elListItem_click.call this, elListItem

  # 点击列表项事件处理
  __elListItem_click = (el) ->
    # 记录被点击项的索引
    if (@_activeItemOnClick) or (@_checkable and @_checkItemOnClick)
      indexOfListItem = j3.Dom.indexOf el

    # 设置被点击列表项为当前项
    if @_activeItemOnClick
      @setActiveIndex indexOfListItem

    # 切换被点击列表项的选中/未选中状态
    if @_checkable and @_checkItemOnClick
      @toggleSelectedIndex indexOfListItem, el

  # 触发command事件
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

  # 切换指定项的选中与未选中状态
  __toggleSelectedIndex = (index, elListItem) ->
    Dom = j3.Dom

    args = {}
    css = 'list-item-checked'
    dataItem = __getDataItemByIndex.call this, index
    if Dom.hasCls elListItem, css
      args.unselectedItems = [dataItem]
      Dom.removeCls elListItem, css
    else
      args.selectedItems = [dataItem]
      Dom.addCls elListItem, css

    __updateSelectedItems.call this, args.selectedItems, args.unselectedItems

    @fire 'selectedItemsChange', this, args

  # 更新@_selectItems中的数据
  __updateSelectedItems = (selectedItems, unselectedItems) ->
    if not @_selectedItems then @_selectedItems = []

    if selectedItems
      for item in selectedItems
        index = j3.indexOf @_selectedItems, item
        if index is -1 then @_selectedItems.push item

    if unselectedItems
      for item in unselectedItems
        index = j3.indexOf @_selectedItems, item
        if index isnt -1 then @_selectedItems.splice index, 1

  # 获取指定索引的数据项
  __getDataItemByIndex = (index) ->
    datasource = @getDatasource()
    @_itemDataSelector datasource.getAt(index)

  j3.DataList = j3.cls j3.View,
    baseCss : 'data-list'

    onInit : (options) ->
      # 指定呈现列表项html的函数。
      # 如果不需要重用这个列表的话，可以使用这种方式。
      # 否则，建议继承此类，然后重写onRenderDataListItem方法。
      @_listItemRenderer = options.listItemRenderer

      # 指定是否在点击列表项时设置被点击列表项为当前项。
      @_activeItemOnClick = options.activeItemOnClick

      # 指定列表项是否可选择
      @_checkable = options.checkable

      # 指定是否在点击列表项时切换被点击列表项的选中/未选中状态
      @_checkItemOnClick = !!options.checkItemOnClick

      # 指定如何从数据源中的数据项转换成外部需要的数据项
      @_itemDataSelector = j3.compileSelector(options.itemDataSelector || 'id')

      # 指定如何判断数据源中的一个数据项是选中数据项
      @_itemDataEquals = j3.compileEquals(options.itemDataEquals || ['id'])

    onCreated : (options) ->
      j3.on @el, 'click', this, __el_click

      @setDatasource options.datasource

      if @_activeItemIndex is -1
        @_activeItemEl = null
      else
        @_activeItemEl = j3.Dom.byIndex @el, @_activeItemIndex

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
      # 在每次刷新列表的时候重置当前项索引
      @_activeItemIndex = -1

      if datasource
        activeModel = datasource.getActive()
        count = datasource.count()
        datasource.forEach this, (model, args, index) ->
          isActive = activeModel is model
          if isActive then @_activeItemIndex = index
          dataListItem =
            index : index
            count : count
            data : model
            active : isActive
            checked : @shouldListItemSelected model

          @renderDataListItem buffer, dataListItem

    # 呈现列表项，不要重载此函数
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

      if dataListItem.checked
        itemCss += ' list-item-checked'

      buffer.append '<div class="' + itemCss + '">'

      @onRenderDataListItem buffer, dataListItem

      buffer.append '</div>'

    # 呈现列表项内容，派生类可以重载此函数
    onRenderDataListItem : (buffer, dataListItem) ->
      if @_listItemRenderer
        @_listItemRenderer buffer, dataListItem, this
      else if not j3.isUndefined dataListItem.data
        buffer.append dataListItem.data.toString()

    # 获取当前数据项
    getActiveItem : ->
      if @_activeItemIndex is -1 then return null
      __getDataItemByIndex.call this, @_activeItemIndex

    # 获取当前列表项的索引值
    getActiveIndex : ->
      @_activeItemIndex

    # 设置索引指定的列表项为当前项
    setActiveIndex : (index) ->
      if @_activeItemIndex is index then return

      datasource = @getDatasource()
      if datasource
        datasource.setActive datasource.getAt(index)

      @fire 'activeItemChange', this

    # 切换索引指定的列表项的选中/未选中状态
    toggleSelectedIndex : (index) ->
      elListItem = j3.Dom.byIndex @el, index
      __toggleSelectedIndex.call this, index, elListItem


    # 获取选中的数据项
    getSelectedItems : ->
      @_selectedItems

    # 判断一个列表项是否应该被选中
    shouldListItemSelected : (model) ->
      if not @_selectedItems then return

      itemData = @_itemDataSelector model
      for item in @_selectedItems
        if @_itemDataEquals item, itemData then return true

      false

  j3.ext j3.DataList.prototype, j3.DataView
