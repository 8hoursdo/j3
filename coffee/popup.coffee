do (j3) ->
  _curPopups = {}

  __isChildElement = (parent, child) ->
    while child
      if child is parent then return true
      child = child.parentNode
    false
    
  j3.regPopup = (obj, name) ->
    name ?= ''
    curPopup = _curPopups[name]

    if curPopup is obj then return

    if curPopup then curPopup.close()

    _curPopups[name] = obj

  j3.unregPopup = (obj, name) ->
    name ?= ''
    curPopup = _curPopups[name]
    if curPopup is obj
      delete _curPopups[name]

  j3.on window, 'mousedown', (evt) ->
    src = evt.src()
    for name, popup of _curPopups
      if not popup then continue

      inside = __isChildElement popup.el, src
      if not inside
        popup.close()
        delete _curPopups[name]
