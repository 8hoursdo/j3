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
      Dom.append document.body, elBox
      @onCreateDropdownBox @_elDropdownBox

    @fire 'beforeDropdown', this, firstTime:firstTime

    j3.regPopup this, 'dropdown'

    Dom.addCls @el, 'sel-active'
    Dom.show @_elDropdownBox

    # change position of drp-box
    posEl = Dom.position @el
    heightEl = Dom.offsetHeight @el
    Dom.place @_elDropdownBox, posEl.left, posEl.top + heightEl + 2

    # change size of drp-box
    if @_boxWidth > 0
      Dom.offsetWidth @_elDropdownBox, @_boxWidth
    else
      @_elDropdownBox.style.width = ""
      widthEl = Dom.offsetWidth @el
      widthBox = Dom.offsetWidth @_elDropdownBox
      if widthBox < widthEl
        Dom.offsetWidth @_elDropdownBox, widthEl

    @_elDropdownBox.style.height = ''
    maxHeight = 28 * 15
    minHeight = 28 * 8
    wndHeight = Dom.clientHeight()
    scrollTop = document.body.scrollTop
    spaceTop = posEl.top - 2 - scrollTop
    spaceBottom = wndHeight - posEl.top - heightEl - 2 + scrollTop

    showOnTop = false
    boxHeight = Dom.offsetHeight @_elDropdownBox
    if boxHeight > maxHeight
      boxHeight = maxHeight
      needAdjustHeight = true
    if spaceBottom < boxHeight
      showOnTop = spaceTop > spaceBottom
      if needAdjustHeight
        boxHeight = if showOnTop then spaceTop else spaceBottom
        if boxHeight > maxHeight then boxHeight = maxHeight
        if boxHeight < minHeight
          boxHeight = minHeight
      else if spaceTop < boxHeight
        showOnTop = false

    Dom.offsetHeight @_elDropdownBox, boxHeight

    if showOnTop
      topBox = posEl.top - boxHeight - 2
    else
      topBox = posEl.top + heightEl + 2

    Dom.place @_elDropdownBox, posEl.left, topBox

    @fire 'dropdown', this, firstTime:firstTime
    @_isDropdown = true
    return

  getPopupEl : ->
    @_elDropdownBox

  close : ->
    j3.Dom.removeCls @el, 'sel-active'
    j3.Dom.hide @_elDropdownBox
    @fire 'close', this
    @_isDropdown = false
    return
