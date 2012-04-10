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

    getViewData : ->
      id : @id
      method : @_method
      target : @_target

    onCreated : ->
      j3.on @el, 'submit', this, __form_submit
