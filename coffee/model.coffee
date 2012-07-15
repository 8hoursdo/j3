do (j3) ->
  j3.Model = Model = (data, options) ->
      options ?= {}

      @collection = options.collection

      @_data = @get('defaults') or {}
      if data then j3.ext @_data, data
      return

  j3.ext Model.prototype, j3.EventManager, j3.Datasource,
    has : (name) ->
      @_data.hasOwnProperty name

    getData : ->
      if @_data
        j3.clone @_data
      else
        {}

    get : (name, defaultVal) ->
      if j3.isFunction @[name]
        return @[name].call this

      if not @_data then return defaultVal

      if @_data.hasOwnProperty name
        @_data[name]
      else
        defaultVal

    set : (name, value, options) ->
      @_data ?= {}

      if j3.isObject name
        data = name
        options = value

      options ?= {}

      if not @_originalData then @_originalData = j3.clone @_data

      if !data
        if j3.equals @_data[name], value then return
        changedData = {}
        changedData[name] = value
        @_data[name] = value
      else
        if not options.append
          @_data = {}

        for name of data
          value = data[name]
          if j3.equals @_data[name], value then continue
          if not changedData then changedData = {}
          changedData[name] = value
          @_data[name] = value

      @notifyChange
        changedData : changedData
        source : options.source

    notifyChange : (options) ->
      options ?= {}

      args =
        changedData : options.changedData
        source : options.source
        model : this

      @updateViews 'change', args

      if @collection then @collection.updateViews 'change', args

    toJson : (buffer) ->
      j3.toJson @_data, buffer

  j3.getVal = (model, name, defaultVal) ->
    if j3.isFunction model.get
      return model.get name, defaultVal

    if j3.isUndefined model[name]
      return defaultVal

    model[name]

  j3.setVal = (model, name, value, options) ->
    if j3.isFunction model.set
      return model.set name, value, options

    model[name] = value
