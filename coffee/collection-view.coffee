do (j3) ->
  __filter = (model, filterBy) ->
    if j3.isFunction filterBy then return filterBy model

    for name, filter of filterBy
      if j3.isFunction filter
        if not filter model[name], model then return false
      else if model[name] isnt filter then return false
    true

  __select = (model, selector) ->
    if j3.isFunction selector then return selector model

  __sorter = (sortBy) ->
    if j3.isFunction sortBy then return sortBy

    if j3.isString sortBy then sortBy = [sortBy]

    sortRules = []
    for eachSortBy in sortBy
      sortInfo = eachSortBy.split ' '

      sortRule =
        name : sortInfo[0]

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
        res = j3.compare obj1[eachRule.name], obj2[eachRule.name], eachRule.nullGreat
        if eachRule.desc then res *= -1
        
        if res isnt 0 then return res
      0

  __grouper = (groupBy) ->
    if j3.isFunction groupBy then return groupBy

    if j3.isString groupBy
      return (obj) -> value : obj[groupBy]

    if j3.isObject groupBy
      if not groupBy.text
        groupText = null
      else if j3.isFunction groupBy.text
        groupText = groupBy.text
      else
        textName = groupBy.text
        groupText = (obj) -> obj[textName]

      if not groupBy.value
        groupValue = null
      else if j3.isFunction groupBy.value
        groupValue = groupBy.value
      else
        valueName = groupBy.value
        groupValue = (obj) -> obj[valueName]

      return (obj) ->
        groupInfo = {}
        if groupText then groupInfo.text = groupText obj
        if groupValue then groupInfo.value = groupValue obj
        groupInfo

  __group = (models, groupBy, groupSortBy) ->
    grouper = __grouper groupBy
    groups = {}

    for eachModel in models
      groupInfo = grouper eachModel.getData()
      modelGroup = groups[groupInfo.value]
      if not modelGroup
        groupInfo.text ?= groupInfo.value
        groupInfo.items = []
        groups[groupInfo.value] = modelGroup = groupInfo

      modelGroup.items.push eachModel

    modelGroups = []
    for eachGroupValue, eachGroup of groups
      modelGroups.push eachGroup

    if not groupSortBy then groupSortBy = 'value nullGreat'
    modelGroups.sort __sorter groupSortBy

    modelGroups

  j3.CollectionView = j3.cls
    ctor : (options) ->
      @_idName = options.idName || 'id'
      @_selector = options.selector
      @_filterBy = options.filterBy
      @_sortBy = options.sortBy
      @_groupBy = options.groupBy

      @setDatasource options.datasource

    getSelector : ->
      @_selector

    setSelector : (selector, options) ->
      options = options || {}
      @_selector = selector

      if not options.silent
        @refresh()

    getFilterBy : ->
      @_filterBy

    setFilterBy : (filterBy, options) ->
      options = options || {}
      @_filterBy = filterBy

      if not options.silent
        @refresh()

    getSortBy : ->
      @_sortBy

    setSortBy : (sortBy, options) ->
      options = options || {}
      @_sortBy = sortBy

      if not options.silent
        @refresh()

    getGroupBy : ->
      @_groupBy

    setGroupBy : (groupBy, options) ->
      options = options || {}
      @_groupBy = groupBy
      @_modelGroups = null

      if not options.silent
        @updateViews 'group'

    getGroupSortBy : ->
      @_groupSortBy

    setGroupSortBy : (groupBy, options) ->
      options = options || {}
      @_groupSortBy = groupBy

      if not options.silent
        @updateViews 'groupSort'

    getById : (id) ->
      @_idxId[id]

    getAt : (index) ->
      if index < 0 or index >= @_models.length then return null
      @_models[index]

    removeById : (id, options) ->
      @getDatasource().removeById id, options

    getActive : ->
      @_activeModel

    setActive : (model, options) ->
      if @_activeModel is model then return

      options = options || {}

      old = @_activeModel
      @_activeModel = model

      if not options.silent
        @updateViews 'active', old : old, cur : model

    onUpdateView : (datasource, eventName, args) ->
      @refresh()

    forEach : (context, args, callback) ->
      if not @_models then return

      if !args && !callback
        callback = context
        context = null
        args = null
      else if !callback
        callback = args
        args = null
      
      for model in @_models
        callback.call context, model, args

    forEachGroup : (context, args, callback) ->
      if not @_models then return

      if not @_modelGroups then @_modelGroups = __group @_models, @_groupBy, @_groupSortBy

      if !args && !callback
        callback = context
        context = null
        args = null
      else if !callback
        callback = args
        args = null

      for group in @_modelGroups
        callback.call context, group, args

    refresh : ->
      models = []

      distinctor = {}
      # select
      if @_selector
        @_datasource.forEach this, (model) ->
          newModel = __select model, @_selector
          if newModel
            if @_idName
              id = newModel[@_idName]
              if not distinctor[id]
                distinctor[id] = newModel
                models.push newModel
            else
              models.push newModel

        # filter selected models
        if @_filterBy
          filtedModels = []
          for model in models
            if __filter model, @_filterBy
              filtedModels.push model
          models = filtedModels
      else
        # filter
        if @_filterBy
          @_datasource.forEach this, (model) ->
            newModel = model.getData()
            if __filter newModel, @_filterBy
              models.push newModel
        else
          @_datasource.forEach this, (model) ->
            models.push model.getData()

      # sort
      if @_sortBy
        models.sort __sorter @_sortBy

      @_models = []
      @_idxId = {}
      for model in models
        newModel = new j3.Model model
        newModel.collection = this

        @_models.push newModel
        if @_idName
          id = model[@_idName]
          @_idxId[id] = newModel

      @_modelGroups = null

      @updateViews 'refresh'

  j3.ext j3.CollectionView.prototype, j3.DataView
  j3.ext j3.CollectionView.prototype, j3.Datasource
