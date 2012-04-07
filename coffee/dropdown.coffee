j3.Dropdown = j3.cls j3.Selector,
  cssTrigger : 'icon-drp-down'

  onInit : (options) ->
    j3.Dropdown.base().onInit.call this, options

    if !j3.isUndefined options.boxWidth then @_boxWidth = parseInt options.boxWidth

  onTriggerClick : ->
    if @_isDropdown then @close() else @dropdown()
    return

  isDropdown : ->
    @_isDropdown

  dropdown : ->
    Dom = j3.Dom

    firstTime = !@_elDropdownBox

    if firstTime
      elBox = document.createElement 'div'
      elBox.className = 'drp-box'

      @_elDropdownBox = elBox
      Dom.append @el, elBox
      @onCreateDropdownBox @_elDropdownBox

    @fire 'beforeDropdown', this, firstTime:firstTime

    Dom.addCls @el, 'sel-active'
    Dom.show @_elDropdownBox

    # change position of drp-box
    pos = Dom.position @el
    pos.top += Dom.offsetHeight @el
    Dom.place @_elDropdownBox, pos.left, pos.top + 2

    # change size of drp-box
    if @_boxWidth > 0
      Dom.offsetWidth @_elDropdownBox, @_boxWidth
    else
      @_elDropdownBox.style.width = ""
      widthEl = Dom.offsetWidth @el
      widthBox = Dom.offsetWidth @_elDropdownBox
      if widthBox < widthEl
        Dom.offsetWidth @_elDropdownBox, widthEl

    @fire 'dropdown', this, firstTime:firstTime
    @_isDropdown = true
    return

  close : ->
    j3.Dom.removeCls @el, 'sel-active'
    j3.Dom.hide @_elDropdownBox
    @fire 'close', this
    @_isDropdown = false
    return
