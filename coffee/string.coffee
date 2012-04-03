j3.String = do ->
  _regTime = /^\s+|\s+$/g


  _regFormat = /{(\d+)?}/g

  J3String =
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

  if String.prototype.trim
    J3String.trim = (s) ->
      if @isNullOrEmpty s then return ''
      s.trim()
  else
    J3String.trim = (s) ->
      if @isNullOrEmpty s then return ''
      s.replace _regTime, ''

    String.prototype.trim = -> s.replace _regTime, ''

  J3String
