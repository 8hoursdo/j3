do (j3) ->
  if j3.isRunInServer() then return

  _curPopups = {}

  # 判断child是不是parents的子元素
  __isChildElement = (parents, child) ->
    if j3.isArray parents
      while child
        if child in parents then return true
        child = child.parentNode
    else
      while child
        if child is parents then return true
        child = child.parentNode
    false

  j3.regPopup = (obj, name, trigger) ->
    name ?= ''
    curPopup = _curPopups[name]

    if curPopup
      if curPopup.view is obj then return
      curPopup.view.close()

    _curPopups[name] =
      view : obj
      trigger : trigger

  j3.unregPopup = (obj, name) ->
    name ?= ''
    curPopup = _curPopups[name]
    if curPopup && curPopup.view is obj
      delete _curPopups[name]

  j3.on document.body, 'mousedown', (evt) ->
    src = evt.src()
    for name, popup of _curPopups
      if not popup then continue

      parentEls = [popup.view.el]
      if popup.trigger
        parentEls = parentEls.concat popup.trigger

      inside = __isChildElement parentEls, src
      if not inside
        popup.view.close()
        delete _curPopups[name]

    return
