do (j3) ->
  __renderGroup = (buffer, datasource) ->
    datasource.forEachGroup this, (group) ->
      __renderGroupItem.call this, buffer, group, datasource.getActive()

  __renderGroupItem = (buffer, group, activeLink) ->
    buffer.append '<div class="nav-group-item">'
    buffer.append '<div class="nav-list-title">'

    if group.icon
      buffer.append '<i class="' + group.icon + '"></i>'

    buffer.append j3.htmlEncode group.text
    buffer.append '</div>'

    __renderList.call this, buffer, group.items, activeLink

    buffer.append '</div>'

  __renderList = (buffer, links, activeLink) ->
    buffer.append '<ul class="nav-list">'
    renderOptions = commandMode : true
    j3.forEach links, this, (link, args, index) ->
      renderOptions.isActive = activeLink is link
      renderOptions.isFirst = index is 0
      j3.LinkList.renderLinkListItem buffer, link, renderOptions
    buffer.append '</ul>'

  j3.NavGroup = j3.cls j3.View,
    baseCss : 'nav-group'

    onCreated : (options) ->
      if options.datasource
        @setDatasource options.datasource

    onUpdateView : (datasource, eventName, args) ->
      buffer = new j3.StringBuilder
      __renderGroup.call this, buffer, @getDatasource()
      @el.innerHTML = buffer.toString()

  j3.ext j3.NavGroup.prototype, j3.DataView

