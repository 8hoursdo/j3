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

    @_value = options.value

  onCreateDropdownBox : (elBox) ->
    buffer = new j3.StringBuilder
    buffer.append '<ul class="drp-list">'

    @_items && @_items.forEach (item) =>
      buffer.append '<li'
      if item.value == @_value
        buffer.append ' class="active"'
      buffer.append '><a>' + item.text + '</a></li>'

    buffer.append '</ul>'

    elBox.append buffer.toString()
    
    elBox.on 'click a', (evt) =>

  getItems : () ->
    @_items

  setItems : (items) ->
    @_items = items
