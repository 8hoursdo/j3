do (j3) ->
  j3.indexOf = (list, item) ->
    index = -1
    for eachItem in list
      if eachItem is item then index = _i

    index

  j3.group = (list, grouper) ->
    groups = {}
    for eachItem in list
      groupName = grouper(eachItem)

      subList = groups[groupName]
      if not subList then groups[groupName] = subList = []

      subList.push eachItem
    groups
        
