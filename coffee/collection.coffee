do (j3) ->
  _collections = {}

  j3.getCollection = (id) ->
    _collections[id]

  j3.Collection = j3.cls
    ctor : (options) ->
      options ?= {}

      if options.id
        @id = options.id
        _collections[@id] = this

      @_idName = options.idName || 'id'

      if options.id then _collections[options.id] = @

      @_idxId = {}
      @_model = options.model || j3.Model
      @_models = new j3.List
      @_notFoundModels = {}

      @_lazyLoad = options.lazyLoad
      @_url = options.url
      return

    getModel : ->
      @_model
    
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
      if not model then return

      options ?= {}

      if @_activeModel is model
        node = @_models.findNode(model)
        newActiveModel = node.next && node.next.value
        if not newActiveModel then newActiveModel = node.prev && node.prev.value

      @_models.remove model
      delete @_idxId[model.get @_idName]

      if not options.silent
        @updateViews 'remove', model : model
      if newActiveModel
        @setActive newActiveModel, options

    removeById : (id, options) ->
      model = @getById id
      if model then @remove model, options

    removeActive : (options) ->
      if @_activeModel then @remove @_activeModel, options

    clear : (options) ->
      options ?= {}

      @_idxId = {}
      @_models.clear()
      @_notFoundModels = {}
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
        args = old : old, model : model
        @updateViews 'active', args
        @fire 'activeModelChange', this, args

    setActiveByIndex : (index, options) ->
      if index >= @count() or index < 0
        index = -1

      @setActive @getAt(index), options

    getById : (id, callback) ->
      if not id
        callback && callback null
        return null

      model = @_idxId[id]

      if model
        callback && callback model
        return model

      if not @_lazyLoad or @_notFoundModels[id]
        callback && callback null
        return null

      j3.get @_url + id, null, this, (xhr, result) ->
        if xhr.status >= 500
          return callback null
        else if xhr.status >= 400
          @_notFoundModels[id] = true
          return callback null

        @insert result
        callback @_idxId[id]
        return

    getAt : (index) ->
      @_models.getAt index

    count : ->
      @_models.count()

    forEach : (context, args, callback) ->
      @_models.forEach context, args, callback

    tryUntil : (context, args, callback) ->
      @_models.tryUntil context, args, callback

    doWhile : (context, args, callback) ->
      @_models.doWhile context, args, callback

  j3.ext j3.Collection.prototype, j3.Datasource
  j3.ext j3.Collection.prototype, j3.EventManager
