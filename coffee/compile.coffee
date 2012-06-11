do (j3) ->
  j3.compileSelector = (selector) ->
    if j3.isFunction selector then return selector

    if j3.isString selector
      return (source) ->
        j3.getVal source, selector

    if j3.isArray
      return (source) ->
        result = {}
        for name in selector
          result[name] = j3.getVal source, name
        result

    if j3.isObject
      return (source) ->
        result = {}
        for name, value of selector
          result[name] = j3.getVal source, value
        result

  j3.compileEquals = (equals) ->
    if j3.isFunction equals then return equals

    if j3.isString equals
      return (obj1, obj2) ->
        j3.equals j3.getVal(obj1, equals), j3.getVal(obj2, equals)

    if j3.isArray equals
      return (obj1, obj2) ->
        for name in equals
          if not j3.equals j3.getVal(obj1, name), j3.getVal(obj2, name) then return false
        true
