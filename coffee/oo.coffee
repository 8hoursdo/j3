ext = j3.ext = (original, extend) ->
  for prop of extend
    original[prop] = extend[prop]
  return

j3.cls = (base, members) ->
  # j3.cls(members)
  if arguments.length == 1
    members = base
    base = null

  if base then ctorOfBase = base.prototype.ctor

  ctorOfCls = members.ctor

  if ctorOfBase
    if ctorOfCls
      members.ctor = ->
        ctorOfBase.apply this, arguments
        ctorOfCls.apply this, arguments
    else
      members.ctor = ctorOfBase
  else if !ctorOfCls
    member.ctor = ->

  ctor = members.ctor
  proto = ctor.prototype
  if base then @ext proto, base.prototype
  @ext proto, members
  if @has members, 'toString' then proto.toString = members.toString

  ctor.base = ->
    base
  ctor
