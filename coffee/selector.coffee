j3.Selector = j3.cls j3.View,
  css : 'sel'

  template : _.template '<div id="<%=id%>" class="<%=css%>"<%if(disabled){%> disabled="disabled"<%}%>><input type="text" class="<%=css%>-input" /><button type="button" class="<%=css%>-trigger"><i class="<%=cssTrigger%>"></i></button></div>'

  onInit : (options) ->
    @_disabled = !!options.disabled

  getViewData : ->
    id : @id
    css : @css +
      (if @_disabled then ' disabled' else '')
    cssTrigger : @cssTrigger
    disabled : @_disabled

  getDisabled : ->
    @_disabled

  setDisabled : (value) ->
    @_disabled = !!value
    @el.toggleClass 'disabled'

