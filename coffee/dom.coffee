do ->
  _tempDiv = document.createElement 'div'

  j3.append = (target, el) ->
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
