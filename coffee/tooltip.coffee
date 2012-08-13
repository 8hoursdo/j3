do(j3) ->
  j3.Tooltip = Tooltip = j3.cls j3.BoxWithArrow,
    css : 'tooltip'

    onInit : (options) ->
      @_text = options.text || ''

      Tooltip.base().onInit.call this, options

    renderChildren : (sb) ->
      sb.e @_text

    getText : ->
      @_text

    setText : (value) ->
      @_text = value
      @getBody().innerHTML = j3.htmlEncode @_text

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
        bar.setText options.text
        bar.show options.pointAt

  j3.Tooltip.show = (options) ->
    options.placement ?= 'top'

    tooltip = __getPool().gain options
