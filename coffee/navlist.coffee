do (j3) ->
  j3.NavList = j3.cls j3.View,
    onInit : (options) ->
      @setDatasource options.datasource

    onRender : (buffer) ->
      buffer.append '<ul id="' + @id + '" class="nav">'
      @renderList buffer
      buffer.append '</ul>'

    renderList : (buffer) ->
      datasource = @getDatasource()
      if not datasource then return

      activeModel = datasource.getActive()
      datasource.forEach (model) ->
        buffer.append '<li'
        if activeModel is model
          buffer.append ' class="active"'
        buffer.append '>'

        buffer.append '<a'
        url = model.get 'url'
        if url
          buffer.append ' href="' + url + '"'
        buffer.append '>'
        buffer.append model.get 'text'
        buffer.append '</a>'

        buffer.append '</li>'

    onUpdateView : (datasource) ->
      if !@el then return

      buffer = new j3.StringBuilder
      @renderList buffer
      @el.innerHTML = buffer.toString()

  j3.ext j3.NavList.prototype, j3.DataView
      
