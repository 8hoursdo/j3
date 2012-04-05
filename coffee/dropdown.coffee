j3.Dropdown = j3.cls j3.Selector,
  cssTrigger : 'icon-drp-down'

  onTriggerClick : ->
    if @_isDropdown then @close() else @dropdown()
    return

  isDropdown : ->
    @_isDropdown

  dropdown : ->
    firstTime = !@_elDropdownBox

    if firstTime
      elBox = document.createElement 'div'
      elBox.className = 'drp-box'

      @_elDropdownBox = elBox
      j3.Dom.append @el, elBox
      @onCreateDropdownBox @_elDropdownBox

    @fire 'beforeDropdown', this, firstTime:firstTime

    j3.Dom.addCls @el, 'sel-active'
    j3.Dom.show @_elDropdownBox

    # change position of drp-box
    pos = j3.Dom.position @el
    pos.top += j3.Dom.offsetHeight @el
    j3.Dom.place @_elDropdownBox, pos.left, pos.top + 2

    @fire 'dropdown', this, firstTime:firstTime
    @_isDropdown = true
    return

  close : ->
    j3.Dom.removeCls @el, 'sel-active'
    j3.Dom.hide @_elDropdownBox
    @fire 'close', this
    @_isDropdown = false
    return
