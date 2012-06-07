do (j3) ->
  __form_submit = (evt) ->
    @fire 'submit', this

    if @_target is 'ajax'
      evt.stop()
    return

  j3.Form = j3.cls j3.ContainerView,
    baseCss : 'form'

    templateBegin : j3.template '<form id="<%=id%>" class="<%=css%>" method="<%=method%>" target="<%=target%>">'

    templateEnd : j3.template '</form>'

    onInit : (options) ->
      @_method = options.method || 'GET'
      @_target = options.target || 'ajax'
      @_narrowLabel = options.narrowLabel
      @_datasource = options.datasource

    getTemplateData : ->
      id : @id
      css : @getCss() +
        (if @_narrowLabel then ' form-narrow-label' else '')
      method : @_method
      target : @_target

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
      @fire 'action', this, name : name, src : src

  j3.ext j3.Form.prototype, j3.DataView
