do(j3) ->
  j3.Tooltip = Tooltip = j3.cls j3.BoxWithArrow,
    css : 'tooltip'

    onInit : (options) ->
      @_content = options.content || ''
      @_encodeContent = !!options.encodeContent

      Tooltip.base().onInit.call this, options

    renderChildren : (sb) ->
      if @_encodeContent
        sb.e @_content
      else
        sb.a @_content

    getContent : ->
      @_content

    setContent : (content, encodeContent) ->
      @_content = content
      @_encodeContent = !!encodeContent

      @getBody().innerHTML = if @_encodeContent then j3.htmlEncode @_content else @_content

    show : (pointAt) ->
      Dom = j3.Dom

      Dom.show @el
      Dom.place @el, pointAt.x - (@el.offsetWidth / 2), pointAt.y

    hide : ->
      j3.Dom.hide @el
      @fire 'hide', this
      
  _pool = null
  __getPool = ->
    if _pool then return _pool

    _pool = new j3.Pool
      onCreate : (options) ->
        bar = new Tooltip options
        bar.on 'hide', (sender, args) ->
          _pool.release sender

        bar

      onInit : (bar, options) ->
        bar.setContent options.content, options.encodeContent
        bar.show options.pointAt

  j3.Tooltip.show = (options) ->
    options.placement ?= 'top'

    tooltip = __getPool().gain options
