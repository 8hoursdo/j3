do (j3) ->
  __hElClick = (evt) ->
    if not @_commandMode then return

    Dom = j3.Dom

    el = evt.src()
    while el and el isnt @el
      if el.tagName is 'A'
        cmd = Dom.data el, 'cmd'
        if not cmd then continue

        data = Dom.data el, 'data'

        evt.stop()
        @fire 'command', this, src : el, name : cmd, data : data
        return
      el = el.parentNode

  __refreshLinks = ->
    sb = new j3.StringBuilder

    list = @getDatasource() || @_items || []

    options =
      target : @_linkTarget
      commandMode : @_commandMode

    LinkList.renderList sb, list, options

    @el.innerHTML = sb.toString()


  j3.LinkList = LinkList = j3.cls j3.View,
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
      datasource = @getDatasource() || @_items || []

      options =
        id : @id
        css : @getCss()
        target : @_linkTarget
        commandMode : @_commandMode

      LinkList.render datasource, options, buffer

    onUpdateView : (datasource) ->
      if !@el then return
      __refreshLinks.call this

    setItems : (value) ->
      @_items = value
      __refreshLinks.call this

  j3.ext LinkList.prototype, j3.DataView

  j3.ext LinkList,
    render : (list, options, buffer) ->
      sb = if buffer then buffer else new j3.StringBuilder

      sb.a '<ul'
      if options.id
        sb.a ' id="' + options.id + '"'
      if options.css
        sb.a ' class="' + options.css + '"'
      sb.a '>'

      LinkList.renderList sb, list, options

      sb.a '</ul>'

      if not buffer then return sb.toString()

    renderList : (sb, list, options) ->
      if list.getActive
        activeItem = list.getActive()

      listItemOptions =
        target : options.target
        commandMode : options.commandMode

      j3.forEach list, (item, args, index) =>
        if item.hasOwnProperty 'isActive'
          listItemOptions.isActive = item.isActive
        else
          listItemOptions.isActive = activeItem is item
        listItemOptions.isFirst = index is 0
        LinkList.renderLinkListItem sb,
          item,
          listItemOptions

    renderLinkListItem : (sb, model, options) ->
      sb.a '<li class="'
      if options.isActive
        sb.a ' active'
      if options.isFirst
        sb.a ' first'
      sb.a '">'

      sb.a '<a'
      url = j3.getVal model, 'url'

      # 在command模式下自动设置链接地址为javascript:;
      if not url and options.commandMode and j3.getVal model, 'cmd'
        url = 'javascript:;'
      if url
        sb.a ' href="' + url + '"'

      title = j3.getVal model, 'title'
      if title
        sb.a ' title="' + j3.htmlEncode(title) + '"'

      target = j3.getVal model, 'target'
      if not target then target = options.target
      if target
        sb.a ' target="' + target + '"'

      if options.commandMode
        cmd = j3.getVal model, 'cmd'
        if cmd
          sb.a ' data-cmd="' + cmd + '"'

        data = j3.getVal model, 'data'
        if data
          sb.a ' data-data="' + data + '"'

      sb.a '>'
      icon = j3.getVal model, 'icon'
      if icon
        sb.a '<i class="' + icon + '"></i>'

      sb.a j3.htmlEncode(j3.getVal(model, 'text'))
      sb.a '</a>'

      sb.a '</li>'


