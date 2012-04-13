do (j3) ->
  j3.Model = j3.cls
    ctor : (data) ->
      data ?= {}
      @set data
      return

    has : (name) ->
      @_data.hasOwnProperty name

    get : (name) ->
      @_data[name]

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
        for name of data
          value = data[name]
          if j3.equals @_data[name], value then continue
          if not changedData then changedData = {}
          changedData[name] = value
          @_data[name] = value

      @notifyDataChange()

      @fire 'change', this,
        changedData : changedData
        source : options.source

    toJson : (buffer) ->
      j3.toJson @_data, buffer

  j3.ext j3.Model.prototype, j3.EventManager
  j3.ext j3.Model.prototype, j3.Datasource
