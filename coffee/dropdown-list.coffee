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

  onCreated : ->
    j3.DropdownList.base().onCreated.call this

    @setSelectedValue @_selectedValue

  onCreateDropdownBox : (elBox) ->
    buffer = new j3.StringBuilder
    buffer.append '<ul class="drp-list">'

    @_items && @_items.forEach (item) =>
      buffer.append '<li'
      if item.value == @_selectedValue
        buffer.append ' class="active"'
      buffer.append '><a>' + item.text + '</a></li>'

    buffer.append '</ul>'

    j3.Dom.append elBox, buffer.toString()
    @_elDrpList = j3.Dom.byIndex elBox, 0

    j3.on @_elDrpList, 'click', this, (evt) ->
      @setSelectedIndex j3.Dom.indexOf j3.Dom.parent evt.src(), 'li'
      @close()

  getItems : () ->
    @_items

  setItems : (items) ->
    @_items = items

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
      if oldIndex != -1
        Dom.removeCls Dom.byIndex(@_elDrpList, oldIndex), 'active'
      Dom.addCls Dom.byIndex(@_elDrpList, index), 'active'

    item = @_items.getAt index

    @setLabel item.text
    @setText item.text

    oldSelectedValue = @_selectedValue
    oldSelectedIndex = @_selectedIndex

    @_selectedIndex = index
    @_selectedValue = item.value

    @fire 'change', this,
      oldIndex : oldSelectedIndex
      oldValue : oldSelectedValue
      curIndex : @_selectedIndex
      curValue : @_selectedValue

