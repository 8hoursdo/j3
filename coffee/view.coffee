# j3.View defines the way to create an UI control
# You can override these methods:
#  - onInit
#  - onCreate
j3.View = do (j3) ->
  # the seed for generating client id automaticlly
  _idSeed = 0

  # if this is great than 0 when a view is creating,
  # we can know that this view is created during another view is creating.
  _creatingStack = 0

  # a dictionary of views with specified id, indexed by the id
  _views = {}

  # 保存所有的顶级控件，即没有parent属性的控件
  _topViews = {}

  j3.getView = (id) ->
    _views[id]

  __viewCreated = ->
    # get the dom element of view
    @el = j3.$ @id

    if @children
      node = @children.firstNode()
      while node
        __viewCreated.call node.value
        node = node.next

    options = @_options

    # you can override onLoad method to do somthing after view has created,
    # like binding dom events
    @onCreated && @onCreated options

    options.on && this.on options.on
    return

  __viewLoad = ->
    if @children
      node = @children.firstNode()
      while node
        __viewLoad.call node.value
        node = node.next

    @onLoad && @onLoad @_options

    delete @_options
    return

  view = j3.cls
    template : j3.template '<div id="<%=id%>" class="<%=css%>"></div>'

    ctor : (options) ->
      _creatingStack++

      options ?= {}
      @_options = options

      if options.id
        _views[options.id] = @
        
      # generate an client id automatic if it's not specified
      @id = options.id or ('v_' + (++_idSeed))

      # we use 'name' when bind data or send message
      if !j3.isUndefined options.name then @name = options.name

      # parent view of this view.
      @parent = options.parent

      # page of the view.
      # send messages to the page if you want notify status changing of the view.
      # @page.fire 'message', this, name : 'msgName', data : 'msgData'
      # handle the 'message' event of the page in the 'onCreated' method if you are instrested at the status changing of other views.
      @page = options.page || (@parent && @parent.page) || @parent || null

      # container of this view, it should be a dom element or id of element
      @ctnr = j3.$ options.ctnr
      if not @ctnr and @parent then @ctnr = @parent.getBody()
      if not @ctnr then @ctnr = document.body

      # give a chance to extend views to change default options of base view
      if @defaultOptions
        defaultOptions = @defaultOptions()
        for optName, optValue of defaultOptions
          if not options.hasOwnProperty optName then options[optName] = optValue

      # override the default css class if specified
      if options.css then @css = options.css

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

        __viewCreated.call this

        @layout()

      # add me into parent's children
      if @parent
        @parent.getChildren().insert this
      else
        _topViews[@id] = this

      # override this to do sth like loading data.
      if not @parent or _creatingStack == 0
        __viewLoad.call this

      return

    render : (buffer) ->
      ret = not buffer
      if ret
        buffer = new j3.StringBuilder
      @onRender buffer, @getTemplateData()

      if ret
        buffer.toString()

    onRender : (buffer, data) ->
      buffer.append @template data
      return

    getCss : ->
      if @css
        @baseCss + ' ' + @css
      else
        @baseCss

    getTemplateData : ->
      id : @id
      css : @getCss()
      view : @

    getChildren : ->
      if not @children then @children = new j3.List
      @children

    getChildByName :  (name) ->
      if not @children then return null
      @children.tryUntil (child) -> child.name is name

    addChild : (child) ->
      @getChildren().insert child

    createChildren : (options) ->
      if not options.children then return

      lastIndex = options.children.length - 1
      for eachOption, i in options.children
        args =
          index : i
          first : i is 0
          last : i is lastIndex

        eachOption.parent = this
        @createChild eachOption, args
      return

    createChild : (options, args) ->
      @onCreateChild && @onCreateChild options, args

      if not j3.isFunction options.cls then return

      child = new options.cls options
      @onChildCreated && @onChildCreated child, args, options

    getBody : ->
      @elBody || @el

    layout : ->
      # 如果正在执行布局，则无需再次布局
      if @_layouting then return

      # 未添加到Dom树中的控件无需布局，正常情况下不会出现。
      parentNode = @el.parentNode
      if !parentNode then return

      # 子类可以重写canLayout函数以决定是不是需要布局（比如控件隐藏的时候）
      # 如果@canLayout函数返回false，则表示不需要进行布局。
      canLayout = true
      @canLayout && canLayout = @canLayout()
      if not canLayout then return

      # 设置正在布局标志
      @_layouting = yes

      # 计算控件应该占用的空间
      if parentNode is document.body
        # 如果控件被放置于body下，则当控件fill的时候，按照窗口大小计算控件大小。
        # 这样的策略导致body的margin或者padding不为0的时候会有问题。
        rect =
          width : if @_fill & 1 then j3.Dom.clientWidth() else @_width
          height: if @_fill & 2 then j3.Dom.clientHeight() else @_height
      else
        rect =
          width : if @_fill & 1 then j3.Dom.width parentNode else @_width
          height: if @_fill & 2 then j3.Dom.height parentNode else @_height

      # 在设置控件大小之前触发测量控件大小的事件，给控件一个最终决定大小的机会。
      @onMeasure? rect
      @fire 'measure', this, rect

      # 设置控件的大小
      __setWidth.call this, rect.width
      __setHeight.call this, rect.height

      # 对子控件进行布局
      @layoutChildren()
      
      # 布局结束
      @_layouting = no

      @onLayouted? rect
      return

    # 对子控件进行布局
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

    getFill : ->
      @_fill

    show : ->
      j3.Dom.show @el

    hide : ->
      j3.Dom.hide @el

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


  # 重新布局的处理
  # -----------------------

  # 表示是否正在重新布局
  _relayouting = false
  # 表示是否在重新布局结束后，再次重新布局
  _needRelayout = false

  # 表示最后一次布局时的窗口大小，如果大小不变，则无需重新布局
  _lastClientWidth = 0
  _lastClientHeight = 0

  _relayoutTimout = null

  # 浏览器窗口大小改变时，自动对顶级控件重新进行布局
  __resize = (evt) ->
    if _relayouting
      _needRelayout = true
      return

    Dom = j3.Dom
    cw = Dom.clientWidth()
    ch = Dom.clientHeight()

    if cw is _lastClientWidth and ch is _lastClientHeight
      return

    _lastClientWidth = cw
    _lastClientHeight = ch

    clearTimeout _relayoutTimout
    _relayoutTimout = setTimeout __relayout, 100

  __relayout = ->
    Dom = j3.Dom
    cw = Dom.clientWidth()
    ch = Dom.clientHeight()

    _relayouting = true

    for id, view of _topViews
      view.layout()

    _relayouting = false

    if _needRelayout then __resize()

  j3.on window, 'resize', __resize



  view.genId = ->
    'v_' + (++_idSeed)

  view.focusChild = ->
    if not @children then return false

    @children.tryUntil (child) ->
      child.focus && child.focus()

  view

