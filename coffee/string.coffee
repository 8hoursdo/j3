_regFormat = /{(\d+)?}/g

j3.ext j3,
  format : (text) ->
    args = arguments
    if args.length == 0 then return ''
    if args.length == 1 then return text
    text.replace _regFormat, ($0, $1) -> args[parseInt($1) + 1]

  include : (s, s1, s2) ->
    if s2 && s2.length
      return (s2 + s + s2).indexOf(s2 + s1 + s2) > -1
    else
      return s.indexOf(s1) > -1

  isNullOrEmpty : (s) ->
    typeof s is 'undefined' or s is null or s is ''

  isNullOrWhiteSpace : (s) ->
    j3.isNullOrEmpty(s) or s.trim() is ''

  hyphenlize : (s) ->
    converted = ''
    i = -1
    len = s.length
    while ++i < len
      c = s.charAt i
      if c == c.toUpperCase()
        converted += '-' + c.toLowerCase()
      else
        converted += c
    converted

  htmlEncode : (s) ->
    if @isNullOrEmpty s then return ''

    s.replace(/&/g, '&amp;')
     .replace(/</g, '&lt;')
     .replace(/>/g, '&gt;')
     .replace(/"/g, '&quot;')
     .replace(/'/g, '&#x27;')
     .replace(/\//g, '&#x2F;')

  substrEx : (s, bytes) ->
    if j3.isNullOrEmpty s then return ''

    i = 0
    uFF61 = 65377	#parseInt("FF61", 16)
    uFF9F = 65439	#parseInt("FF9F", 16)
    uFFE8 = 65512	#parseInt("FFE8", 16)
    uFFEE = 65518	#parseInt("FFEE", 16)
    while i < s.length and bytes > 0
      c = s.charCodeAt i
      if c < 256 or ((uFF61 <= c) and (c <= uFF9F)) or ((uFFE8 <= c) and (c <= uFFEE))
        bytes -= 1
      else
        bytes -= 2
      i++

    if(s.length > i)
      return s.substr(0, i) + "..."
    return s.substr(0, i)

  startsWith : (s, token) ->
    if not s or not token then return false

    if s.indexOf(token) is 0
      return true

    return false

  endsWith : (s, token) ->
    if not s or not token then return false

    pos = s.length - token.length
    if pos < 0 then return false

    if s.substr(pos) is token
      return true

    return false

if String.prototype.trim
  j3.trim = (s) ->
    if @isNullOrEmpty s then return ''
    s.trim()
else
  j3.trim = (s) ->
    if @isNullOrEmpty s then return ''
    s.replace _regTime, ''

  # see: http://blog.stevenlevithan.com/archives/faster-trim-javascript
  String.prototype.trim = () ->
    s = this
    s = s.replace /^\s\s*/, ''
    ws = /\s/
    i = s.length - 1
    while ws.test s.charAt(i)
      i--
    s.slice 0, i + 1

