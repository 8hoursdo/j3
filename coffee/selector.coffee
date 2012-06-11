do (j3) ->
  __refreshSelectedItems = ->
    sb = new j3.StringBuilder

    isEmpty = true

    if @_multiple
      items = @getSelectedItems()
      if items && items.length
        for item in items
          if not item then continue
          isEmpty = false

          sb.a '<div class="sel-lbl">'
          sb.a j3.htmlEncode(item.text)
          sb.a '<i data-cmd="unselect" class="sel-icon-unselect"></i>'
          sb.a '</div>'
      else
        sb.a j3.htmlEncode(@_placeholder)
    else
      item = @getSelectedItem()
      if item
        isEmpty = false
        sb.a j3.htmlEncode(item.text)
      else
        sb.a j3.htmlEncode(@_placeholder)
    @_elLbls.innerHTML = sb.toString()

    emptyCss = @baseCss + '-empty'
    if isEmpty
      j3.Dom.addCls @el, emptyCss
    else
      j3.Dom.removeCls @el, emptyCss

  __elBar_click = (evt) ->
    @onTriggerClick && @onTriggerClick()
    

  j3.Selector = j3.cls j3.View,
    baseCss : 'sel'

    template : j3.template '<div id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%>><div class="sel-bar"><div class="sel-lbls"></div></div><a class="sel-trigger"><i class="<%=cssTrigger%>"></i></a></div>'

    onInit : (options) ->
      @_disabled = !!options.disabled
      @_multiple = !!options.multiple
      @_placeholder = options.placeholder || ''

    onCreated : () ->
      Dom = j3.Dom
      @_elBar = Dom.firstChild @el
      @_elTrigger = Dom.next @_elBar

      @_elLbls = Dom.firstChild @_elBar

      j3.on @_elTrigger, 'click', this, ->
        @onTriggerClick && @onTriggerClick()

      j3.on @_elBar, 'click', this, __elBar_click

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_disabled then ' disabled' else '')
      cssTrigger : @cssTrigger
      disabled : @_disabled

    getDisabled : ->
      @_disabled

    setDisabled : (value) ->
      @_disabled = !!value
      j3.Dom.toggleCls @el, 'disabled'

    getMultiple : ->
      @_multiple

    setMultiple : (value) ->
      @_multiple = value

    getSelectedItem : ->
      if not @_selectedItems or not @_selectedItems.length then return null

      @_selectedItems[0]

    getSelectedItems : ->
      @_selectedItems || []

    setSelectedItem : (item) ->
      @_selectedItems = [item]

      __refreshSelectedItems.call this

    setSelectedItems : (items) ->
      if j3.isArray items
        @_selectedItems = items
      else if items
        @_selectedItems = [items]
      else
        @_selectedItems = []

      __refreshSelectedItems.call this

    addSelectedItem : (item, silent) ->
      if not @_selectedItems then @_selectedItems = [item]

      index = j3.indexOf @_selectedItems, item
      if index is -1 then @_selectedItems.push item

      if not silent then __refreshSelectedItems.call this

    addSelectedItems : (items) ->
      if not @_selectedItems then @_selectedItems = []

      if j3.isArray items
        for eachItem in items
          @addSelectedItem eachItem, true
      else
        @addSelectedItem items, true

      __refreshSelectedItems.call this

    removeSelectedItem : (item) ->
      if not @_selectedItems then return

      index = j3.indexOf @_selectedItems, item
      if index isnt -1 then @_selectedItems.splice index, 1

      if not silent then __refreshSelectedItems.call this

    removeSelectedItems : (items) ->
      if not @_selectedItems then return

      if j3.isArray items
        for eachItem in items
          @removeSelectedItem eachItem, true
      else
        @removeSelectedItem items, true

      __refreshSelectedItems.call this

    onSetWidth : (width) ->
      Dom = j3.Dom
      Dom.offsetWidth @el, width
      widthLabel = Dom.width(@el) - Dom.offsetWidth(@_elTrigger)
      Dom.offsetWidth @_elBar, widthLabel

