do (j3) ->
  _curPopups = {}

  __isInTarget = (target, x, y) ->
    pos = j3.Dom.position target
    width = j3.Dom.offsetWidth target
    if x < pos.left || x > (pos.left + width)
      return false

    height = j3.Dom.offsetHeight target
    if y < pos.top || y > (pos.top + height)
      return false

    true
    
  j3.regPopup = (obj, name) ->
    name ?= ''
    curPopup = _curPopups[name]

    if curPopup is obj then return

    if curPopup then curPopup.close()

    _curPopups[name] = obj

  j3.on window, 'mousedown', (evt) ->
    pageX = evt.pageX()
    pageY = evt.pageY()
    for name, popup of _curPopups
      if not popup then continue

      el = popup.el
      popup.getPopupEl && el = popup.getPopupEl()
      inside = __isInTarget el, pageX, pageY
      if not inside
        popup.close()
        delete _curPopups[name]
