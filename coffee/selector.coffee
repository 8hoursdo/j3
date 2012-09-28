do (j3) ->
  __refreshSelectedLabels = ->
    sb = new j3.StringBuilder

    isEmpty = true

    if @_multiple
      items = @getSelectedItems()
      if items && items.length
        for item in items
          if not item then continue
          isEmpty = false

          sb.a '<div class="sel-lbl">'
          sb.e item.text || item.name || item.value
          sb.a '<i data-cmd="unselect" class="sel-icon-unselect"></i>'
          sb.a '</div>'
      else
        sb.e @_placeholder
    else
      item = @getSelectedItem()
      if item
        isEmpty = false
        sb.e item.text || item.name || item.value
      else
        sb.e @_placeholder
    @_elLbls.innerHTML = sb.toString()

    emptyCss = @baseCss + '-empty'
    if isEmpty
      j3.Dom.addCls @el, emptyCss
    else
      j3.Dom.removeCls @el, emptyCss

  __elBar_click = (evt) ->
    @onTriggerClick && @onTriggerClick()

  __el_keydown = (evt) ->
    keyCode = evt.keyCode()
    # press 'enter' or 'arrow down'
    if keyCode is 13 or keyCode is 40
      @onTriggerClick && @onTriggerClick()
      evt.stop()

  j3.Selector = j3.cls j3.View,
    baseCss : 'sel'

    template : j3.template '<div id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%> tabindex="0"><div class="sel-inner"><div class="sel-bar"><div class="sel-lbls"></div></div><a class="sel-trigger"><i class="<%=cssTrigger%>"></i></a></div></div>'

    onInit : (options) ->
      @_disabled = !!options.disabled
      @_multiple = !!options.multiple
      @_placeholder = options.placeholder || ''
      @_mini = options.mini

    onCreated : () ->
      Dom = j3.Dom
      @elInner = Dom.firstChild @el
      @_elBar = Dom.firstChild @elInner
      @_elTrigger = Dom.next @_elBar

      @_elLbls = Dom.firstChild @_elBar

      j3.on @_elTrigger, 'click', this, ->
        @onTriggerClick && @onTriggerClick()

      j3.on @_elBar, 'click', this, __elBar_click
      j3.on @el, 'keydown', this, __el_keydown

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_mini then ' sel-mini' else '') +
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
      if @_selectedItems and @_selectedItems.length then @_selectedItems[0] else null

    getSelectedItems : ->
      @_selectedItems || []

    setSelectedItem : (item) ->
      @setSelectedItems item

    setSelectedItems : (items) ->
      @doSetSelectedItems items
      @onSetSelectedItems?()

    doSetSelectedItems : (items) ->
      if items and not j3.isArray items then items = [items]
      
      @_selectedItems = items or []
      __refreshSelectedLabels.call this

    updateSubcomponent : ->
      @_updatingSubcomponent = true
      @onUpdateSubcomponent?()
      @_updatingSubcomponent = false

    isUpdatingSubcomponent : ->
      @_updatingSubcomponent

    onSetWidth : (width) ->
      Dom = j3.Dom
      Dom.offsetWidth @el, width
      widthLabel = Dom.width(@el) - Dom.offsetWidth(@_elTrigger)
      Dom.offsetWidth @_elBar, widthLabel

