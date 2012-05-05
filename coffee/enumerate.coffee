do (j3) ->
  __forEach = (callback) ->
    for eachItem in this
      callback eachItem

  j3.indexOf = (list, item) ->
    index = -1
    for eachItem in list
      if eachItem is item then index = _i

    index

  j3.group = (list, grouper) ->
    groups = {}

    forEach = list.forEach || __forEach
    forEach.call list, (eachItem) ->
      groupName = grouper(eachItem)

      subList = groups[groupName]
      if not subList then groups[groupName] = subList = []

      subList.push eachItem
    groups
        
