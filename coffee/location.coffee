do (j3) ->

  if typeof location is 'undefined' then return

  _lastHref = ''

  __check = ->
    if _lastHref is location.href then return

    _lastHref = location.href
    j3.Location.fire 'change', path : location.pathname

  j3.Location =
    start : ->
      __check()
      #setInterval __check, 250

    goto : (url) ->
      location.href = url

    back : ->
      history.go -1

    refresh : ->
      location.refresh()

  j3.ext j3.Location, j3.EventManager
      
