j3.ContainerView = j3.cls j3.View,
  templateBegin : j3.template '<div id="<%=id%>" class="<%=css%>">'

  templateEnd : j3.template '</div>'
  
  onRender : (buffer, data) ->
    @renderBegin buffer, data

    if @innerHTML
      buffer.append @innerHTML
    else if @children
      @renderChildren buffer

    @renderEnd buffer, data

  renderBegin : (buffer, data) ->
    buffer.append @templateBegin data
    return
      
  renderEnd : (buffer, data) ->
    buffer.append @templateEnd data
    return

  renderChildren : (buffer) ->
    node = @children.firstNode()
    while node
      node.value.render buffer
      node = node.next
    return
