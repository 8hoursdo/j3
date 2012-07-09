do (j3) ->
  _elOverlay = null

  _MIN_OVERLAY_Z_INDEX = 2300
  _zIdxOverlay = _MIN_OVERLAY_Z_INDEX

  __doResize = ->
    Dom = j3.Dom
    s = _elOverlay.style

    s.width = Dom.pageWidth() + 'px'
    s.height = Dom.pageHeight() + 'px'

  __resizeOverlay = ->
    Dom = j3.Dom
    s = _elOverlay.style

    s.width = Dom.clientWidth() + 'px'
    s.height = Dom.clientHeight() + 'px'

    setTimeout __doResize, 0

  j3.Overlay =
    show : ->
      if not _elOverlay
        _elOverlay = j3.Dom.create 'div'
        document.body.appendChild _elOverlay
        s = _elOverlay.style
        s.background = '#000'
        s.position = 'absolute'
        s.top = '0'
        s.left = '0'
        j3.Dom.opacity _elOverlay, 0.3
        j3.on window, 'resize', __resizeOverlay

      _zIdxOverlay += 2
      s = _elOverlay.style
      s.zIndex = _zIdxOverlay

      if _zIdxOverlay is _MIN_OVERLAY_Z_INDEX + 2
        s.display = 'block'
        __resizeOverlay()

      _zIdxOverlay

    hide : ->
      if not _elOverlay then return

      if _zIdxOverlay is _MIN_OVERLAY_Z_INDEX then return

      _zIdxOverlay -= 2
      s = _elOverlay.style
      if _zIdxOverlay is _MIN_OVERLAY_Z_INDEX
        s.width = '0'
        s.height = '0'
        s.display = 'none'
      else
        s.zIndex = _zIdxOverlay

      _zIdxOverlay

