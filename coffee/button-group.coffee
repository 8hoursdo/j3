do (j3) ->
  _activeButton = null

  __childButton_click = (sender, args) ->
    if @_toggle is 'radio'
      if sender is _activeButton then return

      if _activeButton
        _activeButton.setActive false

      _activeButton = sender
      _activeButton.setActive true

    @fire 'click', sender, args

  j3.ButtonGroup = j3.cls j3.ContainerView,
    css : 'btn-grp'

    onInit : (options) ->
      @_toggle = options.toggle

    onCreateChild : (options, args) ->
      options.cls = j3.Button
      options.css = 'btn'
      if args.first then options.css += ' first'
      if args.last then options.css += ' last'

      if @_toggle is 'checkbox'
        options.toggle = true

    onChildCreated : (child) ->
      child.on 'click', this, __childButton_click
