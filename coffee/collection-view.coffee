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

  __grouper = (groupBy) ->
    if j3.isFunction groupBy then return groupBy

    if j3.isString groupBy
      return (obj) -> obj[groupBy]

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

      if not groupBy.id
        groupId = null
      else if j3.isFunction groupBy.id
        groupId = groupBy.id
      else
        idName = groupBy.id
        groupId = (obj) -> obj[idName]

      return (obj) ->
        groupInfo = {}
        if groupText then groupInfo.text = groupText obj
        if groupValue then groupInfo.value = groupValue obj
        if groupId then groupInfo.id = groupId obj
        groupInfo

  __group = ->
    models = @_models
    groupIdName = @_groupIdName
    groupBy = @_groupBy
    groupSortBy = @_groupSortBy

    if not groupBy then return

    grouper = __grouper groupBy
    groupMap = {}
    groupList = []

    for eachModel in models
      groupData = grouper eachModel.getData()
      modelGroup = groupMap[groupData[groupIdName]]
      if not modelGroup
        groupData.items = []
        groupMap[groupData[groupIdName]] = modelGroup = groupData
        groupList.push modelGroup

      modelGroup.items.push eachModel

    if not groupSortBy then groupSortBy = 'id'
    groupList.sort j3.compileSortBy(groupSortBy)

    @_groupList = groupList
    @_groupMap = groupMap
    return

  j3.CollectionView = j3.cls
    ctor : (options) ->
      @_idName = options.idName || 'id'
      @_selector = options.selector
      @_filterBy = options.filterBy
      @_sortBy = options.sortBy

      @_groupIdName = options.groupIdName || 'id'
      @_groupBy = options.groupBy
      @_groupSortBy = options.groupSortBy

      @_model = options.model

      @setDatasource options.datasource

    getModel : ->
      @_model or @getDatasource().getModel() or j3.Model

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
      
      if not options.silent
        __group.call this
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
        args = old : old, model : model
        @updateViews 'active', args
        @fire 'activeModelChange', this, args

    count : ->
      @_models.length

    onUpdateView : (datasource, eventName, args) ->
      @refresh()

    forEach : (context, args, callback) ->
      j3.forEach @_models, context, args, callback

    tryUntil : (context, args, callback) ->
      j3.tryUntil @_models, context, args, callback

    doWhile : (context, args, callback) ->
      j3.doWhile @_models, context, args, callback
      
    forEachGroup : (context, args, callback) ->
      if not @_groupList then return

      if !args && !callback
        callback = context
        context = null
        args = null
      else if !callback
        callback = args
        args = null

      for group, i in @_groupList
        callback.call context, group, args, i

    getGroupById : (id) ->
      if not @_groupMap then return
      @_groupMap[id]

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
        models.sort j3.compileSortBy(@_sortBy)

      @_models = []
      @_idxId = {}
      Model = @getModel()
      for model in models
        newModel = new Model model
        newModel.collection = this

        @_models.push newModel
        if @_idName
          id = model[@_idName]
          @_idxId[id] = newModel

      # group
      __group.call this

      @updateViews 'refresh'

  j3.ext j3.CollectionView.prototype, j3.DataView, j3.Datasource, j3.EventManager
