do (j3) ->
  j3.indexOf = (list, item) ->
    index = -1
    for eachItem in list
      if eachItem is item then index = _i

    index
