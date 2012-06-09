do (j3) ->
  __hElClick = (evt) ->
    if not @_commandMode then return

    el = evt.src()
    while el and el isnt @el
      if el.tagName is 'A'
        cmd = j3.Dom.attr el, 'data-cmd'
        if cmd
          data = j3.Dom.attr el, 'data-data'

          evt.stop()
          @fire 'command', this, src : el, name : cmd, data : data
          return
      el = el.parentNode

  j3.LinkList = j3.cls j3.View,
    baseCss : 'link-list'

    onInit : (options) ->
      @_linkTarget = options.linkTarget
      @_commandMode = options.commandMode
      if options.items then @_items = options.items
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
      if datasource
        activeModel = datasource.getActive()
      else
        datasource = @_items || []

      renderOptions =
        target : @_linkTarget
        commandMode : @_commandMode

      j3.forEach datasource, (model, args, index) =>
        renderOptions.isActive = activeModel is model
        renderOptions.isFirst = index is 0
        j3.LinkList.renderLinkListItem buffer,
          model,
          renderOptions

    onUpdateView : (datasource) ->
      if !@el then return

      buffer = new j3.StringBuilder
      @renderList buffer
      @el.innerHTML = buffer.toString()

  j3.LinkList.renderLinkListItem = (buffer, model, options) ->
    buffer.append '<li class="'
    if options.isActive
      buffer.append ' active"'
    if options.isFirst
      buffer.append ' first"'
    buffer.append '">'

    buffer.append '<a'
    url = j3.getVal model, 'url'
    if url
      buffer.append ' href="' + url + '"'

    title = j3.getVal model, 'title'
    if title
      buffer.append ' title="' + j3.htmlEncode(title) + '"'

    target = j3.getVal model, 'target'
    if not target then target = options.target
    if target
      buffer.append ' target="' + target + '"'

    if options.commandMode
      cmd = j3.getVal model, 'cmd'
      if cmd
        buffer.append ' data-cmd="' + cmd + '"'

      data = j3.getVal model, 'data'
      if data
        buffer.append ' data-data="' + data + '"'

    buffer.append '>'
    icon = j3.getVal model, 'icon'
    if icon
      buffer.append '<i class="' + icon + '"></i>'

    buffer.append j3.htmlEncode(j3.getVal(model, 'text'))
    buffer.append '</a>'

    buffer.append '</li>'
   

  j3.ext j3.LinkList.prototype, j3.DataView
      
