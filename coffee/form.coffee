do (j3) ->
  __form_submit = (evt) ->
    try
      @action 'ok'
    catch ex
      console.log ex

    if @_target is 'ajax'
      evt.stop()
    return

  j3.Form = j3.cls j3.ContainerView,
    baseCss : 'form'

    templateBegin : j3.template '<form id="<%=id%>" class="<%=css%>" method="<%=method%>" target="<%=target%>"><%if(title){%><div class="form-title"><%-title%></div><%}%>'

    templateEnd : j3.template '</form>'

    onInit : (options) ->
      @_method = options.method || 'GET'
      @_target = options.target || 'ajax'
      @_narrowLabel = !!options.narrowLabel
      @_stackedLabel = !!options.stackedLabel
      @_datasource = options.datasource

      @_title = options.title

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_narrowLabel then ' form-narrow-label' else '') +
        (if @_stackedLabel then ' form-stacked-label' else '')
      method : @_method
      target : @_target
      title : @_title

    onCreated : ->
      j3.on @el, 'submit', this, __form_submit

    onCreateChild : (options) ->
      options.form = @
      if @_datasource && not options.datasource then options.datasource = @_datasource

    getDatasource : ->
      @_datasource

    getFormItemByName : (name) ->
      if not @children then return null

      node = @children.firstNode()
      while node
        if node.value.name is name
          return node.value
        node = node.next
      null

    action : (name, src) ->
      args = name : name, src : src

      @onAction? args
      @fire 'action', this, args

    getTarget : ->
      @_target

    focus : ->
      if not @children then return false

      @children.tryUntil (child) ->
        child.focus && child.focus()
      return true

  j3.ext j3.Form.prototype, j3.DataView
