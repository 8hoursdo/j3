do (j3) ->
  if j3.isRunInServer() then return

  _reqSeed = 0

  _contentTypes =
    text : 'text/pain'
    json : 'application/json'
    form : 'application/x-www-form-urlencoded'

  # the XMLHttpRequest factory
  if window.XMLHttpRequest
    __getXHR = -> new XMLHttpRequest
  else
    __getXHR = -> new ActiveXObject 'MSXML2.XmlHttp'


  __serializeToFormUrlencoded = (data, buffer) ->
    if not data then return

    firstItem = yes
    for name, value of data
      if data.hasOwnProperty name
        if j3.isNull(value) or j3.isUndefined(value)
          continue

        if not firstItem
          buffer.append '&'
        else
          firstItem = no

        buffer.append encodeURIComponent name
        buffer.append '='
        buffer.append encodeURIComponent value
    return

  # serialize the body to be send
  __serializeBody = (buffer, data, dataType) ->
    switch dataType
      when 'text'
        buffer.append data
      when 'json'
        j3.toJson data, buffer
      else
        __serializeToFormUrlencoded data, buffer
    return

  __parseResponse = (xhr) ->
    contentType = xhr.getResponseHeader('Content-Type')
    if !contentType then contentType = ''

    if contentType.indexOf 'application/json' == 0
      return j3.fromJson xhr.responseText

    xhr.responseText

  # process the request
  __doRequest = (req) ->
    xhr = __getXHR()
    url = req.url
    # IE can not pass empty string to xhr.open()
    if not url then url = location.href

    # make async requests as default
    async = req.async isnt false

    if j3.UA.ie and req.method is 'GET'
      if url.indexOf('?') is -1
        url += '?'
      else
        url += '&'
      url += '_j3ts=' + (new Date().getTime()) + (_reqSeed++)

    if req.method is 'POST'
      # for safari iOS 6
      if not req.headers then req.headers = {}
      req.headers['Cache-Control'] = 'no-cache'

    xhr.open req.method, url, async, req.username, req.password

    # set headers
    headers = req.headers
    xhr.setRequestHeader 'Content-Type', _contentTypes[req.dataType] || _contentTypes.form
    if headers
      for name of headers
        if headers.hasOwnProperty name
          xhr.setRequestHeader name, headers[name]

    # set async callback
    if async
      xhr.onreadystatechange = ->
        if xhr.readyState isnt 4 then return

        req.callback && req.callback.call req.context, xhr, __parseResponse(xhr), req.args

    if req.method is 'GET' or not req.data
      xhr.send ''
    else
      # set request body
      buffer = new j3.StringBuilder
      __serializeBody buffer, req.data, req.dataType
      
      # now send the request
      xhr.send buffer.toString()
    xhr

  # generate http functions
  for method in ['GET', 'POST', 'PUT', 'DELETE']
    j3[method.toLowerCase()] = do (method) ->
      # option
      # url, context, callback
      # url, data, context, callback
      # url, data, context, args, callback
      ->
        url = arguments[0]
        if j3.isObject url
          options = url
        else
          options = {}

          if arguments.length == 3
            context = arguments[1]
            callback = arguments[2]
            data = null
          else if arguments.length == 4
            data = arguments[1]
            context = arguments[2]
            callback = arguments[3]
          else if arguments.length == 5
            data = arguments[1]
            context = arguments[2]
            args = arguments[3]
            callback = arguments[4]

          options.method = method
          options.data = data
          options.dataType = 'json'
          options.url = url
          options.callback = callback
          options.context = context
          options.args = args

        __doRequest options
