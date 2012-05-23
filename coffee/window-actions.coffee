do (j3) ->
  __actionButton_click = (sender, args) ->
    @_window.action sender.name, sender

  j3.WindowActions = j3.cls j3.ContainerView,
    baseCss : 'wnd-actions'

    templateBegin : j3.template '<div id="<%=id%>" class="<%=css%>">'

    templateEnd : j3.template '</div>'

    onInit : (options) ->
      @_window = options.window
      @_window ?= options.parent
      @_align = options.align

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_align is 'right' then ' ' + @baseCss + '-right' else '') +
        (if @_align is 'left' then ' ' + @baseCss + '-left' else '') +
        (if @_align is 'center' then ' ' + @baseCss + '-center' else '')

    onChildCreated : (child) ->
      child.on 'click', this, __actionButton_click
