do (j3) ->
  __form_submit = (evt) ->
    @fire 'submit', this

    if @_target is 'ajax'
      evt.stop()
    return

  j3.Form = j3.cls j3.ContainerView,
    templateBegin : j3.template '<form id="<%=id%>" class="form" method="<%=method%>" target="<%=target%>">'

    templateEnd : j3.template '</form>'

    onInit : (options) ->
      @_method = options.method || 'GET'
      @_target = options.target || 'ajax'
      @_datasource = options.datasource

    getViewData : ->
      id : @id
      method : @_method
      target : @_target

    onCreated : ->
      j3.on @el, 'submit', this, __form_submit

    onCreateChild : (options) ->
      options.form = @
      if @_datasource && not options.datasource then options.datasource = @_datasource

    getDatasource : ->
      @_datasource

    action : (name, src) ->
      @fire 'action', this, name : name, src : src

  j3.ext j3.Form.prototype, j3.DataView
