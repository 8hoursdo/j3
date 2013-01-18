do ->
  j3.Path = Path =
    normalize : (path) ->
      if not path then return ''

      path = path.replace /\\/gi, '/'
      path = path.replace /\/\//gi, '/'

    basename : (path, ext) ->
      path = @normalize path

      if j3.endsWith path, '/'
        path = path.substr 0, path.length - 1

      posSlash = path.lastIndexOf '/'
      if posSlash is -1
        basename = path
      else
        basename = path.substr(posSlash + 1)

      if j3.endsWith basename, ext
        basename = basename.substr(0, basename.length - ext.length)

      return basename

    extname : (path) ->
      posDot = path.lastIndexOf '.'
      if posDot is -1 or posDot is (path.length - 1)
        return ''

      path.substr posDot
