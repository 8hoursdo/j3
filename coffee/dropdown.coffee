j3.Dropdown = j3.cls j3.Selector,
  cssTrigger : 'icon-drp-down'

  onCreated : ->
    @el.find('button').on 'click', =>
      @toggle()
    return

  isDropdown : ->
    @_isDropdown

  toggle : ->
    if @_isDropdown then @close() else @dropdown()
    return

  dropdown : ->
    firstTime = !@_elDropdownBox
    @fire 'beforeDropdown', this, firstTime:firstTime

    if firstTime
      elBox = document.createElement 'div'
      elBox.className = 'drp-box'

      @_elDropdownBox = $(elBox)
      @el.append elBox
      @onCreateDropdownBox @_elDropdownBox

    @_elDropdownBox.show()
    @fire 'dropdown', this, firstTime:firstTime
    @_isDropdown = true
    return

  close : ->
    @_elDropdownBox && @_elDropdownBox.hide()
    @fire 'close', this
    @_isDropdown = false
    return
