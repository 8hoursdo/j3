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
      node = @children.first()
      while node
        _viewCreated.call node.value
        node = node.next

    options = @_options

    # you can override onLoad method to do somthing after view has created,
    # like binding dom events
    @onCreated && @onCreated options

    options.on && this.on options.on

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

      delete @_options

    render : (buffer) ->
      @onRender buffer, @getViewData()
      return

    onRender : (buffer, data) ->
      buffer.append @template data
      return

    getViewData : ->
      id : @id
      css : @css

  j3.ext view.prototype, j3.EventManager
  view
