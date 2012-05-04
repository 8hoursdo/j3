do (j3) ->
  _collections = {}

  j3.getCollection = (id) ->
    _collections[id]

  j3.Collection = j3.cls
    ctor : (options) ->
      options ?= {}

      @_idName = options.idName || 'id'

      if options.id then _collections[options.id] = @

      @_idxId = {}
      @_model = options.model || j3.Model
      @_models = new j3.List
      return
    
    insert : (data, options) ->
      options ?= {}

      if data instanceof @_model
        model = data
      else
        model = new @_model data

      id = model.get @_idName
      if id
        @_idxId[id] = model

      model.collection = this
      @_models.insert model

      if not options.silent
        @updateViews 'add', model : model

    remove : (model, options) ->
      options ?= {}

      @_models.remove model
      @updateViews 'remove', model : model

    clear : (options) ->
      options ?= {}

      @_idxId = {}
      @_models.clear()
      if not options.silent
        @updateViews 'refresh'

    loadData : (dataList, options) ->
      options = options || {}

      silent = options.silent
      options.silent = true
      @clear options
      for data in dataList
        @insert data, options

      if not j3.isUndefined options.activeIndex
        @setActive @_models.getAt options.activeIndex

      if not silent
        @updateViews 'refresh'

    getActive : ->
      @_activeModel

    setActive : (model, options) ->
      if @_activeModel is model then return

      options = options || {}

      old = @_activeModel
      @_activeModel = model

      if not options.silent
        @updateViews 'active', old : old, cur : model

    getById : (id) ->
      @_idxId[id]

    forEach : (context, args, callback) ->
      @_models.forEach context, args, callback
      

  j3.ext j3.Collection.prototype, j3.EventManager
  j3.ext j3.Collection.prototype, j3.Datasource
