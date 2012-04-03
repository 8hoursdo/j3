j3.Dropdown = j3.cls j3.Selector,
  cssTrigger : 'icon-drp-down'

  onCreated : ->
    j3.Dropdown.base().onCreated.call this
    @el.find('.sel-trigger').on 'click', =>
      @toggle()
    return

  isDropdown : ->
    @_isDropdown

  toggle : ->
    if @_isDropdown then @close() else @dropdown()
    return

  dropdown : ->
    firstTime = !@_elDropdownBox

    if firstTime
      elBox = document.createElement 'div'
      elBox.className = 'drp-box'

      @_elDropdownBox = $(elBox)
      @el.append elBox
      @onCreateDropdownBox @_elDropdownBox

    @fire 'beforeDropdown', this, firstTime:firstTime

    @el.addClass 'sel-active'
    @_elDropdownBox.show()

    # change position of drp-box
    pos = j3.Dom.position @el[0]
    pos.top += j3.Dom.offsetHeight @el[0]
    j3.Dom.place @_elDropdownBox[0], pos.left, pos.top + 2

    @fire 'dropdown', this, firstTime:firstTime
    @_isDropdown = true
    return

  close : ->
    @el.removeClass 'sel-active'
    @_elDropdownBox && @_elDropdownBox.hide()
    @fire 'close', this
    @_isDropdown = false
    return
