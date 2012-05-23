j3.Pool = (options) ->
  @_maxSize = options.maxSize || -1
  @_data = []
  @_usedSize = 0
  @_poolSize = 0

  @__onCreate = options.onCreate
  @__onInit = options.onInit
  @__onRelease = options.onRelease
  @__onDestroy = options.onDestroy

j3.ext j3.Pool.prototype,
  getMaxSize : ->
    @_maxSize

  setMaxSize : (value) ->
    if value is -1 or value > @_maxSize
      @_maxSize = value

  getUsedSize : ->
    @_usedSize

  canGain : ->
    @_usedSize isnt @_maxSize

  gain : (options) ->
    if not @canGain() then return null

    if @_usedSize < @_poolSize
      entry = @_data[@_usedSize]
      
    if not entry
      entry = @__onCreate options

      if not entry then return null

      @_data[@_poolSize++] = entry

    @__onInit entry, options

    @_usedSize++

    entry

  release : (entry) ->
    if not entry then return

    lastEntry = @_data[@_usedSize - 1]
    if entry isnt lastEntry
      i = 0
      while i < @_usedSize
        if entry is @_data[i]
          @_data[i] = lastEntry
          break
        i++

      @_data[@_usedSize - 1] = entry

    @__onRelease? entry
    @_usedSize--
    return
  

