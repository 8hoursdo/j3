do (j3) ->
  __forEach = (callback) ->
    for eachItem in this
      callback eachItem

  j3.indexOf = (list, item) ->
    index = -1
    for eachItem in list
      if eachItem is item then index = _i

    index

  j3.forEach = (list, context, args, callback) ->
    if !args && !callback
      callback = context
      context = null
      args = null
    else if !callback
      callback = args
      args = null

    if j3.isArray list
      for eachItem in list
        callback.call context, eachItem, args
    else if list.forEach
      list.forEach context, args, callback

    return

  j3.group = (list, grouper) ->
    groups = {}

    forEach = list.forEach || __forEach
    forEach.call list, (eachItem) ->
      groupName = grouper(eachItem)

      subList = groups[groupName]
      if not subList then groups[groupName] = subList = []

      subList.push eachItem
    groups
        
