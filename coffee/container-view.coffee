j3.ContainerView = j3.cls j3.View,
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
