do (j3) ->
  j3.Panel = j3.cls j3.ContainerView,
    baseCss : 'pnl'

    templateBegin : j3.template '<div id="<%=id%>" class="<%=css%>"><div class="pnl-header"><%if(icon){%><i class="<%=icon%>"></i><%}%><%=title%></div><div class="pnl-body">'

    templateEnd : j3.template '</div></div>'

    onInit : (options) ->
      @_icon = options.icon
      @_title = options.title

    getTemplateData : ->
      id : @id
      css : @getCss()
      icon : @_icon
      title : @_title


