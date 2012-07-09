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

