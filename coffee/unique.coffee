do (j3) ->
  j3.Unique = Unique = (options) ->
    @_array = []
    @_ignoreEmpty = options.ignoreEmpty

  Unique.prototype.getArray = ->
    @_array

  Unique.prototype.add = (items) ->
    if arguments.length is 0 then return

    if @_ignoreEmpty
      if j3.isUndefined items then return
      if j3.isNull items then return

    if j3.isArray items
      for eachItem in items
        __addToArray.call this, eachItem
    else
      __addToArray.call this, items

  __addToArray = (item) ->
    for eachItem in @_array
      if j3.equals eachItem, item then return
    @_array.push item
