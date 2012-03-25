if j3.UA.ie >= 8 or j3.UA.opera or j3.UA.webkit
  j3.StringBuilder = j3.cls
    ctor : ->
      @_data = ''
      return

    append : (text) ->
      @_data += text
      this

    clear : ->
      @_data = ''
      this

    toString : ->
      @_data
else
  j3.StringBuilder = j3.cls
    ctor : ->
      @_data = []
      return

    append : (text) ->
      @_data[@_data.length] = text
      this

    clear : ->
      @_data = []
      this

    toString : ->
      @_data.join ''
  

