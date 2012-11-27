do (j3) ->
  # 点击列表事件处理
  __el_click = (evt) ->
    Dom = j3.Dom
    el = evt.src()

    elListItem = null
    while el and el isnt @el
      # 如果点击了包含data-cmd属性的元素，则触发command事件
      cmd = Dom.data el, 'cmd'
      if cmd
        evt.stop()
        __commandEl_click.call this, cmd, el

        # 如果点击了command元素，不再处理列表项被点击事件（至少目前是这样子的）
        return

      # 点击了列表项中的checkbox
      if el.className is 'list-item-chk'
        __elListItemChk_click.call this, el
        return

      # 点击了列表项
      if Dom.hasCls el, 'list-item'
        __elListItem_click.call this, el
        return

      # 点击列表头中的checkbox
      if el.className is 'list-group-chk'
        __elListGroupChk_click.call this, el
        return

      # 点击分组头
      if el.className is 'list-group-header'
        __elListGroupHeader_click.call this, el
        return

      el = el.parentNode

  __commandArgs_getGroupData = ->
    elGroup = j3.Dom.parent @src, '.list-group'
    if not elGroup then return null

    __getGroupDataByListGroupEl.call @sender, elGroup

  # 点击包含data-cmd属性的元素
  __commandEl_click = (name, elCommand) ->
    Dom = j3.Dom

    elListItem = null
    el = elCommand
    while el and el isnt @el
      if Dom.hasCls el, 'list-item'
        # 点击了ListItem中的某个元素
        data = __getItemDataByListItemEl.call this, el
        break

      if Dom.hasCls el, 'list-group'
        # 点击了分组中的某个元素
        data = __getGroupDataByListGroupEl.call this, el
        break

      el = el.parentNode

    args =
      sender : this
      name : name
      data : data
      src : elCommand
      getGroupData : __commandArgs_getGroupData

    @onCommand? args
    @fire 'command', this, args

  # 点击列表项内的复选框
  __elListItemChk_click = (elListItemChk) ->
    elListItem = j3.Dom.parent elListItemChk, '.list-item'
    __toggleSelectListItem.call this, elListItem

  # 点击列表项
  __elListItem_click = (elListItem) ->
    if not @_itemCheckable or not @_checkItemOnClick then return
    __toggleSelectListItem.call this, elListItem

  # 点击列表头中的chk
  __elListGroupChk_click = (elListGroupChk) ->
    elListGroup = j3.Dom.parent elListGroupChk, '.list-group'
    __toggleSelectListGroup.call this, elListGroup

  # 点击列表头
  __elListGroupHeader_click = (elListGroupHeader) ->
    if not @_groupCheckable or not @_checkGroupOnClick then return

    elListGroup = j3.Dom.parent elListGroupHeader, '.list-group'
    __toggleSelectListGroup.call this, elListGroup

  # 切换列表项的选中/未选中状态
  __toggleSelectListItem = (elListItem) ->
    Dom = j3.Dom

    args = {}
    css = 'list-item-checked'
    itemData = __getItemDataByListItemEl.call this, elListItem
    if Dom.hasCls elListItem, css
      args.unselectedItems = [itemData]
      Dom.removeCls elListItem, css
    else
      args.selectedItems = [itemData]
      Dom.addCls elListItem, css

    __updateSelectedItems.call this, args.selectedItems, args.unselectedItems
    __refreshListItemSelecteStates.call this

    @fire 'selectedItemsChange', this, args

  # 更新@_selectedItems中的数据
  __updateSelectedItems = (selectedItems, unselectedItems) ->
    if not @_selectedItems then @_selectedItems = []

    if selectedItems
      for item in selectedItems
        index = j3.indexOf @_selectedItems, item, @_itemDataEquals
        if index is -1 then @_selectedItems.push item

    if unselectedItems
      for item in unselectedItems
        index = j3.indexOf @_selectedItems, item, @_itemDataEquals
        if index isnt -1 then @_selectedItems.splice index, 1

    return

  # 刷新列表项的选中状态
  __refreshListItemSelecteStates = ->
    if not @el then return

    Dom = j3.Dom
    elListGroup = @el.firstChild
    while elListGroup
      elList = elListGroup.lastChild
      elListItem = elList.firstChild

      while elListItem
        itemData = __getItemDataByListItemEl.call this, elListItem
        if j3.indexOf(@_selectedItems, itemData, @_itemDataEquals) < 0
          Dom.removeCls elListItem, 'list-item-checked'
        else
          Dom.addCls elListItem, 'list-item-checked'

        elListItem = Dom.next elListItem

      elListGroup = Dom.next elListGroup

  # 切换列表组的选中/未选中状态
  __toggleSelectListGroup = (elListGroup) ->
    Dom = j3.Dom

    args = {}
    css = 'list-group-checked'
    groupData = __getGroupDataByListGroupEl.call this, elListGroup
    if Dom.hasCls elListGroup, css
      args.unselectedGroups = [groupData]
      Dom.removeCls elListGroup, css
    else
      args.selectedGroups = [groupData]
      Dom.addCls elListGroup, css

    __updateSelectedGroups.call this, args.selectedGroups, args.unselectedGroups

    @fire 'selectedGroupsChange', this, args

  # 更新@_selectGroups中的数据
  __updateSelectedGroups = (selectedGroups, unselectedGroups) ->
    if not @_selectedGroups then @_selectedGroups = []

    if selectedGroups
      for group in selectedGroups
        index = j3.indexOf @_selectedGroups, group, @_groupDataEquals
        if index is -1 then @_selectedGroups.push group

    if unselectedGroups
      for group in unselectedGroups
        index = j3.indexOf @_selectedGroups, group, @_groupDataEquals
        if index isnt -1 then @_selectedGroups.splice index, 1

    return

  __getItemDataByListItemEl = (elListItem) ->
    @_itemDataSelector @getDatasource().getById j3.Dom.data elListItem, 'id'

  __getGroupDataByListGroupEl = (elListGroup) ->
    @_groupDataSelector @getDatasource().getGroupById(j3.Dom.data elListGroup, 'id')

  # 刷新列表，在数据源发生改变时被调用
  __refreshList = ->
    if not @el then return

    buffer = new j3.StringBuilder
    @renderDataListGroups buffer, @getDatasource()
    @el.innerHTML = buffer.toString()

  j3.GroupedDataList = j3.cls j3.View,
    baseCss : 'data-list-groups'

    onInit : (options) ->
      # DataList Options
      @_listCss = options.listCss
      @_itemRenderer = options.itemRenderer
      @_activeItemOnClick = options.activeItemOnClick
      @_itemCheckable = options.itemCheckable
      @_checkItemOnClick = !!options.checkItemOnClick
      @_itemIdName = options.itemIdName || 'id'
      @_itemDataSelector = j3.compileSelector(options.itemDataSelector || @_itemIdName)
      @_itemDataEquals = j3.compileEquals(options.itemDataEquals || [@_itemIdName])
      @_shouldListItemSelected = options.shouldListItemSelected
      @_selectedItemsEx = options.selectedItemsEx

      # Group Options
      @_groupRenderer = options.groupRenderer
      @_groupCheckable = options.groupCheckable
      @_checkGroupOnClick = !!options.checkGroupOnClick
      @_groupIdName = options.groupIdName || 'id'
      @_groupDataSelector = j3.compileSelector(options.groupDataSelector || @_groupIdName)
      @_groupDataEquals = j3.compileSelector(options.groupDataEquals || [@_groupIdName])
      @_shouldListGroupSelected = options.shouldListGroupSelected
      @_selectedGroupsEx = options.selectedGroupsEx

    onCreated : (options) ->
      j3.on @el, 'click', this, __el_click

      @setDatasource options.datasource

    onUpdateView : (datasource, eventName, data) ->
      __refreshList.call this

    onRender : (sb, tplData) ->
      sb.a '<div id="' + tplData.id + '" class="' + tplData.css + '">'
      @renderDataListGroups sb, @getDatasource()
      sb.a '</div>'

    renderDataListGroups : (sb, datasource) ->
      if not datasource then return

      datasource.forEachGroup this, (groupData, args, index) ->
        listGroupInfo =
          data : groupData
          checkable : @_groupCheckable
          checked : @shouldListGroupSelected groupData
          index : index

        @renderDataListGroup sb, listGroupInfo

    renderDataListGroup : (sb, listGroupInfo) ->
      groupCss = 'list-group'
      if listGroupInfo.index is 0
        groupCss += ' list-group-first'
      if listGroupInfo.checked
        groupCss += ' list-group-checked'

      groupId = j3.getVal listGroupInfo.data, @_groupIdName
      sb.a '<div class="' + groupCss + '" data-id="' + groupId + '">'

      sb.a '<div class="list-group-header">'
      @onRenderDataListGroup sb, listGroupInfo
      sb.a '</div>'

      @renderDataList sb, listGroupInfo.data.items

      sb.a '</div>'

    # 呈现列表分组内容，派生类可以重载此函数
    onRenderDataListGroup : (sb, listGroupInfo) ->
      if @_groupRenderer
        @_groupRenderer.call this, sb, listGroupInfo
      else if not j3.isUndefined listGroupInfo.data
        sb.e listGroupInfo.data.toString()

    renderDataList : (sb, dataItems) ->
      listCss = 'data-list'
      if @_listCss
        listCss += ' ' + @_listCss

      args = buffer : sb
      @beforeRenderDataList && @beforeRenderDataList args
      @fire 'beforeRenderDataList', this, args

      sb.a '<div class="' + listCss + '">'
      @renderDataListItems sb, dataItems, null
      sb.a '</div>'

      @afterRenderDataList && @afterRenderDataList args
      @fire 'afterRenderDataList', this, args

    renderDataListItems : (buffer, datasource, activeModel) ->
      # 在每次刷新列表的时候重置当前项索引
      @_activeItemIndex = -1

      if datasource
        count = j3.count datasource
        j3.forEach datasource, this, (model, args, index) ->
          isActive = activeModel is model
          if isActive then @_activeItemIndex = index
          dataListItem =
            index : index
            count : count
            data : model
            active : isActive
            checkable : @_itemCheckable
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

      itemId = j3.getVal dataListItem.data, @_itemIdName
      buffer.append '<div class="' + itemCss + '" data-id="' + itemId + '">'

      @onRenderDataListItem buffer, dataListItem

      buffer.append '</div>'

    # 呈现列表项内容，派生类可以重载此函数
    onRenderDataListItem : (buffer, dataListItem) ->
      if @_itemRenderer
        @_itemRenderer.call this, buffer, dataListItem
      else if not j3.isUndefined dataListItem.data
        buffer.append dataListItem.data.toString()

    # 获取选中的分组
    getSelectedGroups : ->
      @_selectedGroups

    # 获取选中的数据项
    getSelectedItems : ->
      @_selectedItems

    setSelectedItems : (value) ->
      @_selectedItems = value
      __refreshListItemSelecteStates.call this

    # 判断一个列表组是否应该被选中
    shouldListGroupSelected : (model) ->
      if @_shouldListGroupSelected then return @_shouldListGroupSelected model

      if not @_selectedGroupsEx then return

      groupData = @_groupDataEquals model
      !!j3.tryUntil @_selectedGroupsEx, (group) ->
        if @_groupDataEquals group, groupData then return true

    # 判断一个列表项是否应该被选中
    shouldListItemSelected : (model) ->
      if @_shouldListItemSelected then return @_shouldListItemSelected model

      if not @_selectedItems then return

      itemData = @_itemDataSelector model
      !!j3.tryUntil @_selectedItems, this, (item) ->
        if @_itemDataEquals item, itemData then return true

    getItemCheckable : ->
      @_itemCheckable

    setItemCheckable : (value) ->
      @_itemCheckable = !!value

    getGroupCheckable : ->
      @_groupCheckable

    setGroupCheckable : (value) ->
      @_groupCheckable = !!value

    setSelectedItemsEx : (value) ->
      @_selectedItemsEx = value

  j3.ext j3.GroupedDataList.prototype, j3.DataView
