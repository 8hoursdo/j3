do (j3) ->
  __forEach = (callback) ->
    for eachItem in this
      callback eachItem

  j3.indexOf = (list, item, equals) ->
    if not list then return -1

    index = -1
    equals ?= j3.equals

    j3.tryUntil list, (eachItem, args, i) ->
      if equals(eachItem, item)
        index = i
        true

    index

  j3.contains = (list, item, equals) ->
    -1 isnt j3.indexOf list, item, equals

  j3.in = j3.contains

  j3.remove = (list, item, equals) ->
    if list.remove
      return list.remove item, equals

    if equals
      for eachItem, i in list
        if equals item, eachItem
          list.splice i, 1
          return eachItem
    else if item.equals
      for eachItem, i in list
        if item.equals eachItem
          list.splice i, 1
          return eachItem
    else
      for eachItem, i in list
        if item == eachItem
          list.splice i, 1
          return eachItem
    return

  j3.count = (list) ->
    if j3.isArray list
      list.length
    else
      if not list then return 0

      list.count()

  j3.forEach = (list, context, args, callback) ->
    if not list then return

    if !args && !callback
      callback = context
      context = null
      args = null
    else if !callback
      callback = args
      args = null

    if j3.isArray list
      for eachItem, i in list
        callback.call context, eachItem, args, i
    else if list.forEach
      list.forEach context, args, callback

    return

  j3.tryUntil = (list, context, args, callback) ->
    if not list then return

    if !args && !callback
      callback = context
      context = null
      args = null
    else if !callback
      callback = args
      args = null

    if j3.isArray list
      for eachItem, i in list
        if callback.call context, eachItem, args, i
          return eachItem
    else if list.tryUntil
      list.tryUntil context, args, callback

    return

  j3.doWhile = (list, context, args, callback) ->
    if not list then return

    if !args && !callback
      callback = context
      context = null
      args = null
    else if !callback
      callback = args
      args = null

    if j3.isArray list
      for eachItem, i in list
        if not callback.call context, eachItem, args, i
          return eachItem
    else if list.doWhile
      list.doWhile context, args, callback

    return

  j3.sortBy = (list, sortBy) ->
    comparer = j3.compileSortBy sortBy
    list.sort comparer

  j3.group = (list, groupBy, selector) ->
    groups = {}

    grouper = j3.compileGroupBy groupBy
    forEach = list.forEach || __forEach
    forEach.call list, (eachItem) ->
      groupName = grouper(eachItem)

      subList = groups[groupName]
      if not subList then groups[groupName] = subList = []

      subList.push if selector then selector eachItem else eachItem
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

  j3.pickFieldVal = (list, options) ->
    if j3.isString options
      options =
        ensureUnique : false
        ignoreEmpty : false
        fieldName : options

    res = []

    # 如果列表中的字段是唯一的，则不要作判断，这样可以提升性能。
    if not options.ensureUnique
      j3.forEach list, (item) ->
        if options.ignoreEmpty and j3.isNullOrUndefined item then return

        res.push j3.getVal item, options.fieldName
      return res

    # 如果列表中的字段不一定唯一，并且可能是数组，则采用较为谨慎的方法。
    map = {}

    j3.forEach list, (item) ->
      value = j3.getVal item, options.fieldName
      if j3.isArray value
        for eachVal in value
          if options.ignoreEmpty and j3.isNullOrUndefined eachVal then return
          
          if not map[eachVal]
            map[eachVal] = true
            res.push eachVal
      else
        if options.ignoreEmpty and j3.isNullOrUndefined value then return

        if not map[value]
          map[value] = true
          res.push value

    res

  j3.toMap = (list, keyName) ->
    map = {}

    j3.forEach list, (item) ->
      key = j3.getVal item, keyName
      map[key] = item

    map

  j3.without = (list, values) ->
    result = []

    j3.forEach list, (item) ->
      if j3.isFunction values
        if not values item then result.push item
      else
        if not j3.tryUntil values, ((value) -> j3.equals item, value)
          result.push item

    result
