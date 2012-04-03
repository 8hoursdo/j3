j3.DropdownList = j3.cls j3.Dropdown,
  onInit : (options) ->
    j3.DropdownList.base().onInit.call this, options

    items = options.items
    list = new j3.List
    if items
      if _.isArray items
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

    elBox.append buffer.toString()
    @_elDrpList = j3.Dom.byIndex elBox[0], 0

    elBox.delegate 'li', 'click', this, (evt) ->
      evt.data.setSelectedIndex j3.Dom.indexOf this
      evt.data.close()

  getItems : () ->
    @_items

  setItems : (items) ->
    @_items = items

  setSelectedValue : (value) ->
    index = 0
    @_items.tryUntil (item) =>
      if item.value == value
        return true
      else
        ++index
        return false

    @setSelectedIndex index

  setSelectedIndex : (index) ->
    if index < 0 && index >= @_items.count() then return

    oldIndex = @_selectedIndex
    if oldIndex == index then return

    if @_elDrpList
      $(j3.Dom.byIndex(@_elDrpList, oldIndex)).removeClass 'active'
      $(j3.Dom.byIndex(@_elDrpList, index)).addClass 'active'

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

