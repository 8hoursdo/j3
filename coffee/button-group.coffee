do (j3) ->
  __childButton_active = (sender, args) ->
    if @_toggle is 'radio' or @_toggle is 'exclusive'
      if @_activeButton
        @_activeButton.setActive false

      @_activeButton = sender

    @fire 'active', sender, args

  __childButton_click = (sender, args) ->
    if @_toggle is 'exclusive'
      @_activeButton = if sender.getActive() then sender else null

    @fire 'click', sender, args

  j3.ButtonGroup = j3.cls j3.ContainerView,
    baseCss : 'btn-grp'

    onInit : (options) ->
      @_toggle = options.toggle

    onCreateChild : (options, args) ->
      options.cls = j3.Button
      if args.first then options.css = 'first'
      if args.last then options.css = 'last'

      if @_toggle
        options.toggle = @_toggle
      return

    onChildCreated : (child) ->
      child.on 'click', this, __childButton_click
      child.on 'active', this, __childButton_active

    setActiveButtonByName : (name) ->
      @getChildren().forEach (btn) ->
        active = btn.name is name
        btn.setActive active
        if active then @_activeButton = btn
