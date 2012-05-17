do (j3) ->
  __hElClick = (evt) ->
    if not @_commandMode then return

    el = evt.src()
    while el and el isnt @el
      if el.tagName is 'A'
        cmd = el.attributes['data-cmd']
        if cmd
          cmd = cmd.nodeValue
          data = el.attributes['data-data']
          if data then data = data.nodeValue

          evt.stop()
          @fire 'command', this, src : el, name : cmd, data : data
          return
      el = el.parentNode

  j3.LinkList = j3.cls j3.View,
    baseCss : 'link-list'

    onInit : (options) ->
      @_linkTarget = options.linkTarget
      @_commandMode = options.commandMode
      @setDatasource options.datasource

    onCreated : (options) ->
      if @_commandMode
        j3.on @el, 'click', this, __hElClick

    onRender : (buffer) ->
      buffer.append '<ul id="' + @id + '" class="' + @getCss() + '">'
      @renderList buffer
      buffer.append '</ul>'

    renderList : (buffer) ->
      datasource = @getDatasource()
      if not datasource then return

      activeModel = datasource.getActive()
      renderOptions =
        target : @_linkTarget
        commandMode : @_commandMode

      datasource.forEach (model) =>
        j3.LinkList.renderLinkListItem buffer,
          model,
          activeModel is model,
          renderOptions

    onUpdateView : (datasource) ->
      if !@el then return

      buffer = new j3.StringBuilder
      @renderList buffer
      @el.innerHTML = buffer.toString()

  j3.LinkList.renderLinkListItem = (buffer, model, isActive, options) ->
    buffer.append '<li'
    if isActive
      buffer.append ' class="active"'
    buffer.append '>'

    buffer.append '<a'
    url = model.get 'url'
    if url
      buffer.append ' href="' + url + '"'

    title = model.get 'title'
    if title
      buffer.append ' title="' + j3.htmlEncode(title) + '"'

    target = model.get 'target'
    if not target then target = options.target
    if target
      buffer.append ' target="' + target + '"'

    if options.commandMode
      cmd = model.get 'cmd'
      if cmd
        buffer.append ' data-cmd="' + cmd + '"'

      data = model.get 'data'
      if data
        buffer.append ' data-data="' + data + '"'

    buffer.append '>'
    buffer.append model.get 'text'
    buffer.append '</a>'

    buffer.append '</li>'
   

  j3.ext j3.LinkList.prototype, j3.DataView
      
