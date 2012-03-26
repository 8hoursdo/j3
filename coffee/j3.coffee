root = this

j3 = root.j3 = ->
  j3.$.apply this, arguments

j3.version = '0.0.1'

j3.has = (obj, prop) ->
  obj.hasOwnProperty prop

j3.$ = root.jQuery or (query) ->
  if typeof query is 'string'
    if (query.indexOf '#') == 0
      return document.getElementById query.substr 1
    else
      return null

  return query
