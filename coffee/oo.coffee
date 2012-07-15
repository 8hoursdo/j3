j3.ns = (nameSpace) ->
  names = nameSpace.split "."
  
  curNS = if typeof window is 'undefined' then global else window

  for name in names
    if not curNS[name]
      curNS[name] = {}
    curNS = curNS[name]
  curNS
  
ext = j3.ext = (original, exts...) ->
  for extend in exts
    for prop of extend
      original[prop] = extend[prop]
  original

j3.cls = (base, members) ->
  # j3.cls(members)
  if arguments.length == 1
    members = base
    base = null

  ctorOfCls = members.ctor

  if base
    if ctorOfCls
      members.ctor = ->
        base.apply this, arguments
        ctorOfCls.apply this, arguments
    else
      members.ctor = ->
        base.apply this, arguments
  else if !ctorOfCls
    members.ctor = ->

  ctor = members.ctor
  proto = ctor.prototype
  if base then @ext proto, base.prototype
  @ext proto, members
  if @has members, 'toString' then proto.toString = members.toString

  ctor.base = ->
    base.prototype
  ctor
