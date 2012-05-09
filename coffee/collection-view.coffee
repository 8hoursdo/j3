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

    return (obj1, obj2) ->
      j3.compare obj1[sortBy], obj2[sortBy]

  j3.CollectionView = j3.cls
    ctor : (options) ->
      @_idName = options.idName
      @_selector = options.selector
      @_filterBy = options.filterBy
      @_sortBy = options.sortBy
      @_groupBy = options.groupBy

      @setDatasource options.datasource

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

    sortBy : (sortBy, options) ->
      options = options || {}
      @_sortBy = sortBy

      if not options.silent
        @refresh()

    groupBy : (groupBy, options) ->
      options = options || {}
      @_groupBy = groupBy

      if not options.silent
        @refresh()

    getById : (id) ->
      @getDatasource().getById id

    getAt : (index) ->
      if index < 0 or index >= @_models.length then return null
      @_models[index]

    removeById : (id, options) ->
      @getDatasource().removeById id, options

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

    refresh : ->
      models = []

      @_idxId = {}
      # select
      if @_selector
        @_datasource.forEach this, (model) ->
          newModel = __select model, @_selector
          if newModel
            if @_idName
              id = newModel[@_idName]
              if not @_idxId[id]
                @_idxId[id] = newModel
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
      for model in models
        @_models.push new j3.Model model

      @updateViews 'refresh'

  j3.ext j3.CollectionView.prototype, j3.DataView
  j3.ext j3.CollectionView.prototype, j3.Datasource
