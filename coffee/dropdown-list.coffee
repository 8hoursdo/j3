do (j3) ->
  __renderListItems = (items, buffer) ->
    items && items.forEach (item) =>
      buffer.append '<li'
      if item.value == @_selectedValue
        buffer.append ' class="active"'
      buffer.append '><a>' + item.text + '</a></li>'

  __elDrpList_click = (evt) ->
    @setSelectedIndex j3.Dom.indexOf j3.Dom.parent evt.src(), 'li'
    @close()
    evt.stop()

  j3.DropdownList = j3.cls j3.Dropdown,
    _selectedIndex : -1

    onInit : (options) ->
      j3.DropdownList.base().onInit.call this, options

      items = options.items
      list = new j3.List
      if items
        if j3.isArray items
          for eachItem in items
            eachItem.value ?= eachItem.text
            list.insert eachItem
        else if items instanceof j3.List
          items.forEach (item) ->
            item.value ?= item.text
            list.insert item
          @_items = options.items
      @_items = list
      @_selectedValue = options.value

    onCreated : (options) ->
      j3.DropdownList.base().onCreated.call this

      @setSelectedValue @_selectedValue
      @setDatasource options.datasource

    onCreateDropdownBox : (elBox) ->
      buffer = new j3.StringBuilder
      buffer.append '<ul class="drp-list">'

      __renderListItems.call this, @_items, buffer

      buffer.append '</ul>'

      j3.Dom.append elBox, buffer.toString()
      @_elDrpList = j3.Dom.byIndex elBox, 0

      j3.on @_elDrpList, 'click', this, __elDrpList_click

    getItems : () ->
      @_items

    setItems : (items) ->
      @_items = items
      if @_elDrpList
        buffer = new j3.StringBuilder
        __renderListItems.call this, @_items, buffer
        @_elDrpList.innerHTML = buffer.toString()

    getSelectedValue : ->
      @_selectedValue

    setSelectedValue : (value) ->
      index = 0
      @_items.tryUntil (item) =>
        if item.value == value
          return true
        else
          ++index
          return false

      if index == @_items.count() then index = -1
      @setSelectedIndex index

    getSelectedIndex : ->
      @_selectedIndex

    setSelectedIndex : (index) ->
      if index < 0 && index >= @_items.count() then return

      oldIndex = @_selectedIndex
      if oldIndex == index then return

      Dom = j3.Dom
      if @_elDrpList
        if oldIndex isnt -1
          Dom.removeCls Dom.byIndex(@_elDrpList, oldIndex), 'active'
        if index isnt -1
          Dom.addCls Dom.byIndex(@_elDrpList, index), 'active'

      item = @_items.getAt index

      @setLabel item.text
      @setText item.text

      oldSelectedValue = @_selectedValue
      oldSelectedIndex = @_selectedIndex

      @_selectedIndex = index
      @_selectedValue = item.value

      @updateData()

      @fire 'change', this,
        oldIndex : oldSelectedIndex
        oldValue : oldSelectedValue
        curIndex : @_selectedIndex
        curValue : @_selectedValue

    onUpdateData : ->
      @_datasource.set @name, @_selectedValue

    onUpdateView : ->
      @setSelectedValue @_datasource.get @name

  j3.ext j3.DropdownList.prototype, j3.DataView

