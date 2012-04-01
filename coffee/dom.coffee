do ->
  _tempDiv = document.createElement 'div'

  dom = j3.Dom = {}

  dom.append = (target, el) ->
    if not target then return

    if typeof el is 'string'
      _tempDiv.innerHTML = el
      if _tempDiv.childNodes.length > 1
        els = []
        while _tempDiv.firstChild
          els[els.length] = target.appendChild _tempDiv.firstChild
        return els
      return target.appendChild _tempDiv.firstChild

    target.appendChild el

  dom.indexOf = (el) ->
    debugger
    p = el.parentNode
    if !p then return -1

    index = 0
    for childNode in p.childNodes
      if childNode.nodeType == 1
        if childNode == el then return index
        ++index
    return -1
