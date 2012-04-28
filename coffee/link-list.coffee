do (j3) ->
  j3.LinkList = j3.cls j3.View,
    baseCss : 'link-list'

    onInit : (options) ->
      @_linkTarget = options.linkTarget
      @setDatasource options.datasource

    onRender : (buffer) ->
      buffer.append '<ul id="' + @id + '" class="' + @getCss() + '">'
      @renderList buffer
      buffer.append '</ul>'

    renderList : (buffer) ->
      datasource = @getDatasource()
      if not datasource then return

      activeModel = datasource.getActive()
      datasource.forEach (model) =>
        buffer.append '<li'
        if activeModel is model
          buffer.append ' class="active"'
        buffer.append '>'

        buffer.append '<a'
        url = model.get 'url'
        if url
          buffer.append ' href="' + url + '"'

        title = model.get 'title'
        if title
          buffer.append ' title="' + j3.htmlEncode(title) + '"'

        target = @_linkTarget
        target = model.get 'target'
        if not target then target = @_linkTarget
        if target
          buffer.append ' target="' + @_linkTarget + '"'

        buffer.append '>'
        buffer.append model.get 'text'
        buffer.append '</a>'

        buffer.append '</li>'

    onUpdateView : (datasource) ->
      if !@el then return

      buffer = new j3.StringBuilder
      @renderList buffer
      @el.innerHTML = buffer.toString()

  j3.ext j3.LinkList.prototype, j3.DataView
      
