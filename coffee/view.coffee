# j3.View defines the way to create an UI control
# You can override these methods:
#  - onInit
#  - onCreate
j3.View = do ->
  # the seed for generating client id automaticlly
  _idSeed = 0

  # if this is great than 0 when a view is creating,
  # we can know that this view is created during another view is creating.
  _creatingStack = 0

  _viewCreated = ->
    # get the dom element of view
    @el = j3.$ @id

    if @children
      node = @children.firstNode()
      while node
        _viewCreated.call node.value
        node = node.next

    options = @_options

    # you can override onLoad method to do somthing after view has created,
    # like binding dom events
    @onCreated && @onCreated options

    options.on && this.on options.on
    delete @_options
    return

  view = j3.cls
    ctor : (options) ->
      _creatingStack++

      options ?= {}
      @_options = options

      # generate an client id automatic if it's not specified
      @id = options.id or ('v_' + (++_idSeed))

      # parent view of this view.
      @parent = options.parent

      # container of this view, it should be a dom element
      @ctnr = j3.$ options.ctnr

      # override this method to set properties of view
      @onInit && @onInit options

      # layout options
      if !j3.isUndefined options.width then @_width = parseInt options.width
      if !j3.isUndefined options.height then @_height = parseInt options.height
      if !j3.isUndefined options.minWidth then @_minWidth = parseInt options.minWidth
      if !j3.isUndefined options.maxWidth then @_maxWidth = parseInt options.maxWidth
      if !j3.isUndefined options.maxHeight then @_maxHeight = parseInt options.maxHeight
      if !j3.isUndefined options.minHeight then @_minHeight = parseInt options.minHeight
      @_fill = parseInt(options.fill) or 0


      @innerHTML = options.innerHTML

      # create child views
      @createChildren && @createChildren options

      _creatingStack--

      # generate dom of view
      if not @parent or _creatingStack == 0
        buffer = new j3.StringBuilder
        @render buffer
        j3.Dom.append @ctnr, buffer.toString()

        _viewCreated.call this

        if not @parent then @layout()
        else if _creatingStack == 0 then @parent.addChild this

      return

    render : (buffer) ->
      @onRender buffer, @getViewData()
      return

    onRender : (buffer, data) ->
      buffer.append @template data
      return

    getViewData : ->
      id : @id
      css : @css

    getChildren : ->
      if not @children then @children = new j3.List
      @children

    addChild : (child) ->
      @getChildren().insert child

    createChildren : (options) ->
      if not options.children then return

      for eachOption in options.children
        if not j3.isFunction eachOption.cls then continue

        eachOption.parent = this
        child = new eachOption.cls eachOption
        @getChildren().insert child

    layout : ->
      if @_layouting then return

      parentNode = @el.parentNode
      if !parentNode then return

      @_layouting = yes

      if parentNode is document.body
        rect =
          width : if @_fill & 1 then j3.Dom.clientWidth() else @_width
          height: if @_fill & 2 then j3.DOm.clientHeight() else @_height
      else
        rect =
          width : if @_fill & 1 then j3.Dom.width parentNode else @_width
          height: if @_fill & 2 then j3.DOm.height parentNode else @_height

      __setWidth.call this, rect.width
      __setHeight.call this, rect.height

      @layoutChildren()
      
      @_layouting = no
      return

    layoutChildren : ->
      if !@children then return

      node = @children.firstNode()
      while node
        node.value.layout()
        node = node.next
      return

    width : (width, delayLayout) ->
      # get width
      if arguments.length == 0 then return @_width

      # set width
      @_width = width
      # don't change width if this view is set to fill horizonal
      if @_fill & 1 then return

      @onSetWidth width

      if !delayLayout then @layoutChildren()

    height : (height, delayLayout) ->
      # get height
      if arguments.length == 0 then return @_height

      # set height
      @_height = height
      if @_fill & 2 then return

      @onSetHeight height
      
      if !delayLayout then @layoutChildren()

    onSetWidth : (width) ->
      j3.Dom.offsetWidth @el, width

    onSetHeight : (height) ->
      j3.Dom.offsetHeight @el, height

  j3.ext view.prototype, j3.EventManager

  __setWidth = (width) ->
    if @_maxWidth and width > @_maxWidth then width = @_maxWidth
    if @_minWidth and width < @_minWidth then width = @_minWidth
    @onSetWidth width
    return

  __setHeight = (height) ->
    if @_maxHeight and height > @_maxHeight then height = @_maxHeight
    if @_minHeight and height < @_minHeight then height = @_minHeight
    @onSetHeight height

  view
