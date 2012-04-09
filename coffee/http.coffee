do (j3) ->
  # the XMLHttpRequest factory
  if window.XMLHttpRequest
    __getXHR = -> new XMLHttpRequest
  else
    __getXHR = -> new ActiveXObject 'MSXML2.XmlHttp'


  __serializeToFormUrlencoded = (buffer, data) ->
    if not data then return

    firstItem = yes
    for name of data
      if data.hasOwnProperty name
        if not firstItem
          buffer.append '&'
        else
          firstItem = yes

        buffer.append encodeURIComponent name
        buffer.append '='
        buffer.append encodeURIComponent data[name]

  __serializeToJson = (buffer, data) ->
    

  # serialize the body to be send
  __serializeBody = (buffer, data, contentType) ->
    switch contentType
      when 'text'
        buffer.append data
      when 'json'
        __serializeToJson buffer, data
      else
        __serializeToFormUrlencoded buffer, data
    return

  __parseResponse = (xhr) ->
    

  # process the request
  __doRequest = (req) ->
    xhr = __getXHR()
    url = req.url
    async = req.async isnt false
    headers = req.headers

    xhr.open req.method, req.url, async, req.username, req.password

    # set headers
    if headers
      for name of headers
        if headers.hasOwnProperty name
          xhr.setRequestHeader name, headers[name]

    # set async callback
    if async
      xhr.onreadystatechange = ->
        if xhr.readyState isnt 4 then return

        req.callback && req.callback.call req.context, xhr, __parseResponse xhr

    if req.method is 'GET' or not req.data
      xhr.send ''
    else
      # set request body
      buffer = new j3.StringBuilder
      __serializeBody buffer, req.data
      
      # now send the request
      xhr.send buffer.toString()
    xhr

  # generate http functions
  for method in ['get', 'post', 'put', 'delete']
    j3[method] = do (method) ->
      (url, data, callback, context, options) ->
        if arguments.length < 5
          options = context
          context = callback
          callback = data
          data = null

        options = options || {}
        options.method = method
        options.data = data
        options.url = url
        options.callback = callback
        options.context = context

        __doRequest options
