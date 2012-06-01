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

  __getChildItems = (list, parentId, options) ->
    idName = options.idName
    parentName = options.parentName
    childrenName = options.childrenName

    children = []

    j3.forEach list, (item) ->
      if parentId is j3.getVal item, parentName
        children.push item
        j3.setVal item, childrenName, __getChildItems(list, j3.getVal(item, idName), options)

    if children.length
      return children
    return null

  j3.tree = (list, options) ->
    options ?= {}
    options.idName ?= 'id'
    options.parentName ?= 'parentId'
    options.childrenName ?= 'children'

    idName = options.idName
    parentName = options.parentName
    childrenName = options.childrenName

    itemsDictionary = {}
    j3.forEach list, (item) ->
      itemsDictionary[j3.getVal item, idName] = item

    rootItems = []
    j3.forEach list, (item) ->
      if not j3.getVal item, parentName
        rootItems.push item
        j3.setVal item, childrenName, __getChildItems(list, j3.getVal(item, idName), options)

    rootItems
