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
      @_idxId = {}
      @_model = options.model || j3.Model
      @_models = new j3.List
      @_notFoundModels = {}

      @_lazyLoad = options.lazyLoad
      @_url = options.url

      @_contextData = options.contextData

      options.on && @on options.on
      return

    getModel : ->
      @_model

    getContextData : ->
      @_contextData

    setContextData : (value) ->
      if @_contextData is value then return

      @_contextData = value
    
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
      target = null
      if not j3.isUndefined options.targetIndex
        target = @_models.getNodeAt options.targetIndex
      @_models.insert model, target

      if not options.silent
        args =
          model : model
        @updateViews 'add', args
        @fire 'addModel', this, args

    remove : (model, options) ->
      if not model then return

      options ?= {}

      node = @_models.findNode model
      if @_activeModel is model
        newActiveModel = node.next && node.next.value
        if not newActiveModel then newActiveModel = node.prev && node.prev.value

      delete @_idxId[model.get @_idName]
      @_models.removeNode node

      if not options.silent
        args =
          model : model
        @updateViews 'remove', args
        @fire 'removeModel', this, args
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
        @fire 'refresh', this

    loadData : (dataList, options) ->
      dataList = dataList || []
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
        @fire 'refresh', this

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

    notifyModelChange : (changeName, args) ->
      @updateViews changeName, args
      @fire changeName, this, args

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
