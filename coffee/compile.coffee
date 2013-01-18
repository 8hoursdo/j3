do (j3) ->
  j3.compileSelector = (selector) ->
    if not selector then return (source) -> source
      
    if j3.isFunction selector then return selector

    if j3.isString selector
      return (source) ->
        j3.getVal source, selector

    if j3.isArray selector
      return (source) ->
        result = {}
        for name in selector
          val = j3.getVal source, name
          if not j3.isUndefined val
            result[name] = val
        result

    if j3.isObject selector
      return (source) ->
        result = {}
        for name, value of selector
          if j3.isString value
            val = j3.getVal source, value
          else
            val = value source
          if not j3.isUndefined val
            result[name] = val
        result

  j3.compileEquals = (equals) ->
    if j3.isFunction equals then return equals

    if j3.isString equals
      return (obj1, obj2) ->
        if obj1 is null
          if obj2 is null
            return true
          else
            return false
        else
          if obj2 is null
            return false
          else
            j3.equals j3.getVal(obj1, equals), j3.getVal(obj2, equals)

    if j3.isArray equals
      return (obj1, obj2) ->
        if obj1 is null
          if obj2 is null
            return true
          else
            return false
        else
          if obj2 is null
            return false
          else
            for name in equals
              if not j3.equals j3.getVal(obj1, name), j3.getVal(obj2, name) then return false
            true

  j3.compileSortBy = (sortBy) ->
    if j3.isFunction sortBy then return sortBy

    if j3.isString sortBy then sortBy = [sortBy]

    sortRules = []
    for eachSortBy in sortBy
      sortInfo = eachSortBy.split ' '

      sortRule =
        name : sortInfo[0]

      if sortRule.name.indexOf('?') is 0
        sortRule.name = sortRule.name.substr 1
        sortRule.bool = true

      if sortInfo.length > 1
        for info in sortInfo.slice 1
          if info is 'desc'
            sortRule.desc = true
          else if info is 'nullGreat'
            sortRule.nullGreat = true

      sortRules.push sortRule
    
    return (obj1, obj2) ->
      res = 0
      for eachRule in sortRules
        if eachRule.bool
          res = j3.compare !!j3.getVal(obj1, eachRule.name), !!j3.getVal(obj2, eachRule.name)
        else
          res = j3.compare j3.getVal(obj1, eachRule.name), j3.getVal(obj2, eachRule.name), eachRule.nullGreat
        if eachRule.desc then res *= -1
        
        if res isnt 0 then return res
      0


  _compiledGroupBy = {}

  j3.compileGroupBy = (groupBy) ->
    if j3.isFunction groupBy then return groupBy

    if j3.isString groupBy
      compiledGroupBy = _compiledGroupBy[groupBy]
      if compiledGroupBy then return compiledGroupBy
      
      _compiledGroupBy[groupBy] = compiledGroupBy = (obj) ->
        j3.getVal obj, groupBy

      return compiledGroupBy

