if j3.UA.ie >= 8 or j3.UA.opera or j3.UA.webkit
  j3.StringBuilder = j3.cls
    ctor : ->
      @_data = ''
      return

    append : (text) ->
      @_data += text
      this

    encodeAndAppend : (text) ->
      @_data += j3.htmlEncode text
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

    encodeAndAppend : (text) ->
      @_data[@_data.length] = j3.htmlEncode text
      this

    clear : ->
      @_data = []
      this

    toString : ->
      @_data.join ''

_stringBuilder_proto = j3.StringBuilder.prototype
_stringBuilder_proto.a = _stringBuilder_proto.append
_stringBuilder_proto.e = _stringBuilder_proto.encodeAndAppend
