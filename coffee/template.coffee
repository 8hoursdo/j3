j3.template = do(j3) ->
  templateSettings =
    evaluate    : /<%([\s\S]+?)%>/g
    interpolate : /<%=([\s\S]+?)%>/g
    escape      : /<%-([\s\S]+?)%>/g

  noMatch = /.^/

  escapes =
    '\\': '\\'
    "'": "'"
    'r': '\r'
    'n': '\n'
    't': '\t'
    'u2028': '\u2028'
    'u2029': '\u2029'

  for p of escapes
    escapes[escapes[p]] = p

  escaper = /\\|'|\r|\n|\t|\u2028|\u2029/g

  unescaper = /\\(\\|'|r|n|t|u2028|u2029)/g

  unescape = (code) ->
    code.replace unescaper, (match, escape) -> escapes[escape]

  template = (text, data, settings) ->
    settings = settings || {}
    j3.ext settings, templateSettings

    source = text
      .replace escaper, (match) ->
        '\\' + escapes[match]
      .replace settings.escape or noMatch, (match, code) ->
        "',\nj3.htmlEncode(#{unescape(code)}),\n'"
      .replace settings.interpolate or noMatch, (match, code) ->
        "',\n#{unescape(code)},\n'"
      .replace settings.evaluate or noMatch, (match, code) ->
        "');\n#{unescape(code)}\n;__p.push('"

    sb = new j3.StringBuilder
    sb.append 'var __p=[],print=function(){__p.push.apply(__p,arguments);};\n'
    if !settings.variable
      sb.append 'with(obj||{}){\n'

    sb.append "__p.push('"
    sb.append source
    sb.append "');\n"

    if !settings.variable
      sb.append '}\n'
    sb.append 'return __p.join("");\n'

    render = new Function settings.variable or 'obj', 'j3', sb.toString()
    if data then return render data, j3

    (data) -> render.call this, data, j3

  template
