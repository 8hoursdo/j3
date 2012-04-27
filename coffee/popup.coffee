do (j3) ->
  _curPopup = null

  j3.regPopup = (obj) ->
    if _curPopup then _curPopup.close()

    _curPopup = obj

  j3.on window, 'mousedown', (evt) ->
    if not _curPopup then return

    src = evt.src()
    el = _curPopup.el
    while src
      if el is src then return
      src = src.parentNode

    _curPopup.close()
    _curPopup = null
    