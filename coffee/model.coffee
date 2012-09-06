do (j3) ->
  j3.Model = Model = (data, options) ->
      options ?= {}

      if data and not options.noParse and @parse then data = @parse data

      if defaults = @get('defaults')
        data = j3.ext defaults, data

      @_data = data || {}

      return

  j3.ext Model.prototype, j3.EventManager, j3.Datasource,
    notifyChangeName : 'modelDataChange'

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

      eventName = 'change'
      if !data
        if j3.equals @_data[name], value then return
        changedData = {}
        changedData[name] = value
        @_data[name] = value
      else
        if options.append
          for name of data
            value = data[name]
            if j3.equals @_data[name], value then continue
            if not changedData then changedData = {}
            changedData[name] = value
            @_data[name] = value
        else
          eventName = 'refresh'
          @_data = j3.clone data

      @notifyChange
        eventName : eventName
        changedData : changedData
        source : options.source

    notifyChange : (options) ->
      options ?= {}

      {eventName} = options
      args =
        changedData : options.changedData
        source : options.source
        model : this

      @fire eventName, this, args

      @updateViews eventName, args

      collection = @collection
      collection && collection.notifyModelChange @notifyChangeName, args

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
